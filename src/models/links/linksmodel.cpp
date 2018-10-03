#include "linksmodel.h"
#include "links.h"

LinksModel::LinksModel(QObject *parent)
    : QAbstractListModel(parent)
{
    this->mLinks = new Links(this);
}

int LinksModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mLinks)
        return 0;

    return mLinks->items().size();
}

QVariant LinksModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mLinks)
        return QVariant();

    return mLinks->items().at(index.row())[static_cast<OWL::KEY>(role)];
}

QVariantMap LinksModel::get(const int &index)
{
    QVariantMap res;
    const auto note = mLinks->items().at(index);
    for(auto key : note.keys())
        res.insert(OWL::KEYMAP[key], note[key]);
    return res;
}

void LinksModel::sortBy(const int &index, const QString &order)
{
    beginResetModel();
    mLinks->sortBy(static_cast<OWL::KEY>(index), order);
    endResetModel();
}

bool LinksModel::insert(const QVariantMap &link)
{
    const int index = mLinks->items().size();
    if( this->mLinks->insertLink(link))
    {
        beginInsertRows(QModelIndex(), index, index);
        endInsertRows();
        return true;
    }

    return false;
}

bool LinksModel::remove(const int &index)
{
    if(this->mLinks->removeLink(index))
    {
        beginResetModel();
        endResetModel();
        return true;
    }

    return false;
}

QVariantList LinksModel::getTags(const int &index)
{
    return this->mLinks->getLinkTags(this->mLinks->items().at(index)[OWL::KEY::LINK]);
}

bool LinksModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mLinks)
        return false;

    if (mLinks->updateLink(index.row(), value, role))
    {
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags LinksModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> LinksModel::roleNames() const
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

//Notes *NotesModel::notes() const
//{
//    return mLinks;
//}

//void NotesModel::setNotes(Notes *value)
//{
//    beginResetModel();

//    if(mLinks)
//        mLinks->disconnect(this);
//    mLinks = value;

////    if(mLinks)
////    {
////        connect(mLinks, &Notes::preItemAppended, this, [=]()
////        {
////            const int index = mLinks->items().size();
////            beginInsertRows(QModelIndex(), index, index);
////        });

////        connect(mLinks, &Notes::postItemAppended, this, [=]()
////        {
////            endInsertRows();
////        });

////        connect(mLinks, &Notes::preItemRemoved, this, [=](int index)
////        {
////            beginInsertRows(QModelIndex(), index, index);
////        });

////        connect(mLinks, &Notes::preItemRemoved, this, [=]()
////        {
////            endRemoveRows();
////        });
////    }

//    endResetModel();
//}
