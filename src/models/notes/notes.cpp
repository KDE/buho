#include "notes.h"
#include <QUuid>
#include "db/db.h"
#include "nextnote.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif


Notes::Notes(QObject *parent) : BaseList(parent),
    db(DB::getInstance()),
    tag(Tagging::getInstance()),
    syncer(new NextNote(this))
{
    qDebug()<< "CREATING NOTES LIST";
    this->sortList();

    connect(this, &Notes::sortByChanged, this, &Notes::sortList);
    connect(this, &Notes::orderChanged, this, &Notes::sortList);
}

void Notes::sortList()
{
    emit this->preListChanged();

    syncer->setCredentials("milo.h@aol.com", "Corazon1corazon", "free01.thegood.cloud");
    syncer->getNotes();
//    this->notes = this->db->getDBData(QString("select * from notes ORDER BY %1 %2").arg(
//                                          OWL::KEYMAP[this->sort],
//                                      this->order == ORDER::ASC ? "asc" : "desc"));
    emit this->postListChanged();
}

OWL::DB_LIST Notes::items() const
{
    return this->notes;
}

bool Notes::insert(const QVariantMap &note)
{
    qDebug()<<"TAGS"<< note[OWL::KEYMAP[OWL::KEY::TAG]].toStringList();

    emit this->preItemAppended();

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

        emit postItemAppended();

        return true;
    } else qDebug()<< "NOTE COULD NOT BE INSTED";

    return false;
}

bool Notes::update(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= notes.size())
        return false;

    const auto oldValue = this->notes[index][static_cast<OWL::KEY>(role)];

    if(oldValue == value.toString())
        return false;

    this->notes[index].insert(static_cast<OWL::KEY>(role), value.toString());

    this->update(this->notes[index]);

    return true;
}

bool Notes::update(const QVariantMap &data, const int &index)
{
    if(index < 0 || index >= this->notes.size())
        return false;

    auto newData = this->notes[index];
    QVector<int> roles;

    for(auto key : data.keys())
        if(newData[OWL::MAPKEY[key]] != data[key].toString())
        {
            newData.insert(OWL::MAPKEY[key], data[key].toString());
            roles << OWL::MAPKEY[key];
        }

    this->notes[index] = newData;

    if(this->update(newData))
    {
        emit this->updateModel(index, roles);
        return true;
    }

    return false;
}

bool Notes::update(const OWL::DB &note)
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

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map, {{OWL::KEYMAP[OWL::KEY::ID], id}} );
}

bool Notes::remove(const int &index)
{
    emit this->preItemRemoved(index);
    auto id = this->notes.at(index)[OWL::KEY::ID];
    QVariantMap note = {{OWL::KEYMAP[OWL::KEY::ID], id}};

    if(this->db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], note))
    {
        this->notes.removeAt(index);
        emit this->postItemRemoved();
        return true;
    }

    return false;
}

QVariantList Notes::getTags(const int &index)
{
    if(index < 0 || index >= this->notes.size())
        return QVariantList();

    auto id = this->notes.at(index)[OWL::KEY::ID];
    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::NOTES], id);
}

QVariantMap Notes::get(const int &index) const
{
    if(index >= this->notes.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto note = this->notes.at(index);

    for(auto key : note.keys())
        res.insert(OWL::KEYMAP[key], note[key]);

    return res;
}
