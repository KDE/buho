#include "notes.h"
#include <QUuid>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Notes::Notes(QObject *parent) : DB(parent)
{
    this->notes = this->getNotes();
}

OWL::DB_LIST Notes::items() const
{
    return this->notes;
}

void Notes::appendItem()
{
    emit preItemAppended();

    emit postItemAppended();
}

void Notes::removeItem()
{
   emit  preItemRemoved(0);

   emit postItemRemoved();
}

bool Notes::insertNote(const QVariantMap &note)
{
    qDebug()<<"TAGS"<< note[OWL::KEYMAP[OWL::KEY::TAG]].toStringList();

    auto title = note[OWL::KEYMAP[OWL::KEY::TITLE]].toString();
    auto body = note[OWL::KEYMAP[OWL::KEY::BODY]].toString();
    auto color = note[OWL::KEYMAP[OWL::KEY::COLOR]].toString();
    auto pin = note[OWL::KEYMAP[OWL::KEY::PIN]].toInt();
    auto fav = note[OWL::KEYMAP[OWL::KEY::FAV]].toInt();
    auto tags = note[OWL::KEYMAP[OWL::KEY::TAG]].toStringList();

    auto id = QUuid::createUuid().toString();

    QVariantMap note_map =
    {
        {OWL::KEYMAP[OWL::KEY::ID], id},
        {OWL::KEYMAP[OWL::KEY::TITLE], title},
        {OWL::KEYMAP[OWL::KEY::BODY], body},
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::PIN], pin},
        {OWL::KEYMAP[OWL::KEY::FAV], fav},
        {OWL::KEYMAP[OWL::KEY::UPDATED], QDateTime::currentDateTime().toString()},
        {OWL::KEYMAP[OWL::KEY::ADD_DATE], QDateTime::currentDateTime().toString()}
    };

    if(this->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map))
    {
        for(auto tg : tags)
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

        this->noteInserted(note_map);
        return true;
    }

    return false;
}

bool Notes::updateNote(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= notes.size())
        return false;
    const auto oldNote = this->notes[index][static_cast<OWL::KEY>(role)];

    if(oldNote == value.toString())
        return false;

    this->notes[index].insert(static_cast<OWL::KEY>(role), value.toString());

    const auto newNote = this->notes[index];
    this->updateNote(newNote);

    return true;
}


bool Notes::updateNote(const OWL::DB &note)
{
    auto id = note[OWL::KEY::ID];
    auto title = note[OWL::KEY::TITLE];
    auto body = note[OWL::KEY::BODY];
    auto color = note[OWL::KEY::COLOR];
    auto pin = note[OWL::KEY::PIN].toInt();
    auto fav = note[OWL::KEY::FAV].toInt();
    auto tags = note[OWL::KEY::TAG].split(",", QString::SkipEmptyParts);
    auto updated =note[OWL::KEY::UPDATED];

    QVariantMap note_map =
    {
        {OWL::KEYMAP[OWL::KEY::TITLE], title},
        {OWL::KEYMAP[OWL::KEY::BODY], body},
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::PIN], pin},
        {OWL::KEYMAP[OWL::KEY::FAV], fav},
        {OWL::KEYMAP[OWL::KEY::UPDATED], updated}
    };

    for(auto tg : tags)
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

    return this->update(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map, {{OWL::KEYMAP[OWL::KEY::ID], id}} );
}

bool Notes::removeNote(const QVariantMap &note)
{
    qDebug()<<note;
    return this->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], note);
}

OWL::DB_LIST Notes::getNotes()
{
    return this->getDBData("select * from notes ORDER BY updated ASC");
}

QVariantList Notes::getNoteTags(const QString &id)
{
    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::NOTES], id);
}
