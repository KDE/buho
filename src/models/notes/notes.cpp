#include "notes.h"
#include <QUuid>

#include "db/db.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Notes::Notes(QObject *parent) : QObject(parent)
{
    this->db = DB::getInstance();
    this->tag =  Tagging::getInstance(OWL::App, OWL::version, "org.kde.buho", OWL::comment);
    this->sortBy(OWL::KEY::UPDATED, "DESC");
}

void Notes::sortBy(const OWL::KEY &key, const QString &order)
{
    this->notes = this->db->getDBData(QString("select * from notes ORDER BY %1 %2").arg(OWL::KEYMAP[key], order));
}

OWL::DB_LIST Notes::items() const
{
    return this->notes;
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

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map))
    {
        for(auto tg : tags)
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

        this->notes << OWL::DB
                       ({
                            {OWL::KEY::ID, id},
                            {OWL::KEY::TITLE, title},
                            {OWL::KEY::BODY, body},
                            {OWL::KEY::COLOR, color},
                            {OWL::KEY::PIN, QString::number(pin)},
                            {OWL::KEY::FAV, QString::number(fav)},
                            {OWL::KEY::UPDATED, QDateTime::currentDateTime().toString()},
                            {OWL::KEY::ADD_DATE, QDateTime::currentDateTime().toString()}

                        });
        return true;
    }

    return false;
}

bool Notes::updateNote(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= notes.size())
        return false;

    const auto oldValue = this->notes[index][static_cast<OWL::KEY>(role)];

    if(oldValue == value.toString())
        return false;

    this->notes[index].insert(static_cast<OWL::KEY>(role), value.toString());

    this->updateNote(this->notes[index]);

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


    qDebug()<< "TRYING TO UPDATE TAGS"<< tags;
    for(auto tg : tags)
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map, {{OWL::KEYMAP[OWL::KEY::ID], id}} );
}

bool Notes::removeNote(const QVariantMap &note)
{
    qDebug()<<note;
    return this->db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], note);
}

QVariantList Notes::getNoteTags(const QString &id)
{
    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::NOTES], id);
}
