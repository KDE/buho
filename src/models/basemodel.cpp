#include "basemodel.h"
#include "baselist.h"
#include "notes/notes.h"

BaseModel::BaseModel(QObject *parent)
    : QAbstractListModel(parent),
      mList(nullptr)
{}

int BaseModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant BaseModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();


    return mList->items().at(index.row())[static_cast<OWL::KEY>(role)];
}

bool BaseModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mList)
        return false;

    if (mList->update(index.row(), value, role))
    {
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags BaseModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[OWL::KEY::TITLE] = QString(OWL::KEYMAP[OWL::KEY::TITLE]).toUtf8();
    names[OWL::KEY::BODY] = QString(OWL::KEYMAP[OWL::KEY::BODY]).toUtf8();
    names[OWL::KEY::UPDATED] = QString(OWL::KEYMAP[OWL::KEY::UPDATED]).toUtf8();
    names[OWL::KEY::FAV] = QString(OWL::KEYMAP[OWL::KEY::FAV]).toUtf8();
    names[OWL::KEY::PIN] = QString(OWL::KEYMAP[OWL::KEY::PIN]).toUtf8();
    names[OWL::KEY::COLOR] = QString(OWL::KEYMAP[OWL::KEY::COLOR]).toUtf8();
    names[OWL::KEY::ID] = QString(OWL::KEYMAP[OWL::KEY::ID]).toUtf8();
    names[OWL::KEY::IMAGE] = QString(OWL::KEYMAP[OWL::KEY::IMAGE]).toUtf8();
    names[OWL::KEY::LINK] = QString(OWL::KEYMAP[OWL::KEY::LINK]).toUtf8();
    names[OWL::KEY::PREVIEW] = QString(OWL::KEYMAP[OWL::KEY::PREVIEW]).toUtf8();
    names[OWL::KEY::TAG] = QString(OWL::KEYMAP[OWL::KEY::TAG]).toUtf8();
    names[OWL::KEY::URL] = QString(OWL::KEYMAP[OWL::KEY::URL]).toUtf8();
    names[OWL::KEY::ADD_DATE] = QString(OWL::KEYMAP[OWL::KEY::ADD_DATE]).toUtf8();
    names[OWL::KEY::URL] = QString(OWL::KEYMAP[OWL::KEY::ADD_DATE]).toUtf8();

    return names;
}

BaseList *BaseModel::getList() const
{
    return this->mList;
}

void BaseModel::setList(BaseList *value)
{
    beginResetModel();

    if(mList)
        mList->disconnect(this);

    mList = value;

    if(mList)
    {
        connect(this->mList, &BaseList::preItemAppended, this, [=]()
        {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &BaseList::postItemAppended, this, [=]()
        {
            endInsertRows();
        });

        connect(this->mList, &BaseList::preItemRemoved, this, [=](int index)
        {
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(this->mList, &BaseList::postItemRemoved, this, [=]()
        {
            endRemoveRows();
        });

        connect(this->mList, &BaseList::updateModel, this, [=](int index, QVector<int> roles)
        {
            emit this->dataChanged(this->index(index), this->index(index), roles);
        });

        connect(this->mList, &BaseList::preListChanged, this, [=]()
        {
            beginResetModel();
        });

        connect(this->mList, &BaseList::postListChanged, this, [=]()
        {
            endResetModel();
        });
    }

    endResetModel();
}
