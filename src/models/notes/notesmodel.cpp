#include "notesmodel.h"
#include "notes.h"

NotesModel::NotesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    this->mNotes = new Notes(this);
}

int NotesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mNotes)
        return 0;

    return mNotes->items().size();
}

QVariant NotesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mNotes)
        return QVariant();

    return mNotes->items().at(index.row())[static_cast<OWL::KEY>(role)];
}

QVariantMap NotesModel::get(const int &index)
{
    QVariantMap res;
    const auto note = mNotes->items().at(index);
    for(auto key : note.keys())
        res.insert(OWL::KEYMAP[key], note[key]);
    return res;
}

void NotesModel::sortBy(const int &index, const QString &order)
{
    beginResetModel();
    mNotes->sortBy(static_cast<OWL::KEY>(index), order);
    endResetModel();
}

bool NotesModel::insert(const QVariantMap &note)
{
    const int index = mNotes->items().size();
    beginInsertRows(QModelIndex(), index, index);
    this->mNotes->insertNote(note);
    endInsertRows();
    return false;
}

QVariantList NotesModel::getTags(const int &index)
{
    qDebug()<< "CURRENT INDEX FOR "<< index;
    return this->mNotes->getNoteTags(this->mNotes->items().at(index)[OWL::KEY::ID]);
}

bool NotesModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mNotes)
        return false;

    if (mNotes->updateNote(index.row(), value, role))
    {
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags NotesModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> NotesModel::roleNames() const
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
//    return mNotes;
//}

//void NotesModel::setNotes(Notes *value)
//{
//    beginResetModel();

//    if(mNotes)
//        mNotes->disconnect(this);
//    mNotes = value;

////    if(mNotes)
////    {
////        connect(mNotes, &Notes::preItemAppended, this, [=]()
////        {
////            const int index = mNotes->items().size();
////            beginInsertRows(QModelIndex(), index, index);
////        });

////        connect(mNotes, &Notes::postItemAppended, this, [=]()
////        {
////            endInsertRows();
////        });

////        connect(mNotes, &Notes::preItemRemoved, this, [=](int index)
////        {
////            beginInsertRows(QModelIndex(), index, index);
////        });

////        connect(mNotes, &Notes::preItemRemoved, this, [=]()
////        {
////            endRemoveRows();
////        });
////    }

//    endResetModel();
//}
