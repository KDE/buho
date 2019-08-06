#include "notes.h"
#include <QUuid>
#include "db/db.h"
#include "nextnote.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#endif

Notes::Notes(QObject *parent) : MauiList(parent),
    db(DB::getInstance()),
    tag(Tagging::getInstance()),
    syncer(new NextNote(this))
{
    qDebug()<< "CREATING NOTES LIST";
    this->sortList();

    connect(this, &Notes::sortByChanged, this, &Notes::sortList);
    connect(this, &Notes::orderChanged, this, &Notes::sortList);
    connect(syncer, &NextNote::notesReady, [&](FMH::MODEL_LIST notes)
    {
        emit this->preListChanged();
        this->notes << notes;
        emit this->postListChanged();
    });
}

void Notes::sortList()
{
    emit this->preListChanged();  
    this->notes = this->db->getDBData(QString("select * from notes ORDER BY %1 %2").arg(
                                          FMH::MODEL_NAME[static_cast<FMH::MODEL_KEY>(this->sort)],
                                      this->order == ORDER::ASC ? "asc" : "desc"));
    emit this->postListChanged();
}

FMH::MODEL_LIST Notes::items() const
{
    return this->notes;
}

void Notes::setSortBy(const Notes::SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

Notes::SORTBY Notes::getSortBy() const
{
    return this->sort;
}

void Notes::setOrder(const Notes::ORDER &order)
{
    if(this->order == order)
        return;

    this->order = order;
    emit this->orderChanged();
}

Notes::ORDER Notes::getOrder() const
{
    return this->order;
}

bool Notes::insert(const QVariantMap &note)
{
    qDebug()<<"TAGS"<< note[FMH::MODEL_NAME[FMH::MODEL_KEY::TAG]].toStringList();

    emit this->preItemAppended();

    auto title = note[FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE]].toString();
    auto content = note[FMH::MODEL_NAME[FMH::MODEL_KEY::CONTENT]].toString();
    auto color = note[FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR]].toString();
    auto pin = note[FMH::MODEL_NAME[FMH::MODEL_KEY::PIN]].toInt();
    auto fav = note[FMH::MODEL_NAME[FMH::MODEL_KEY::FAVORITE]].toInt();
    auto tags = note[FMH::MODEL_NAME[FMH::MODEL_KEY::TAG]].toStringList();

    auto id = QUuid::createUuid().toString();

    QVariantMap note_map =
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::CONTENT], content},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], color},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::PIN], pin},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAVORITE], fav},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MODIFIED], QDateTime::currentDateTime().toString()},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime().toString()}
    };

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map))
    {
        for(auto tg : tags)
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

        this->notes << FMH::MODEL
                       ({
                            {FMH::MODEL_KEY::ID, id},
                            {FMH::MODEL_KEY::TITLE, title},
                            {FMH::MODEL_KEY::CONTENT, content},
                            {FMH::MODEL_KEY::COLOR, color},
                            {FMH::MODEL_KEY::PIN, QString::number(pin)},
                            {FMH::MODEL_KEY::FAVORITE, QString::number(fav)},
                            {FMH::MODEL_KEY::MODIFIED, QDateTime::currentDateTime().toString()},
                            {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString()}

                        });

        emit postItemAppended();

        this->syncer->insertNote(FM::toModel(note_map));

        return true;
    } else qDebug()<< "NOTE COULD NOT BE INSTED";

    return false;
}

bool Notes::update(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= notes.size())
        return false;

    const auto oldValue = this->notes[index][static_cast<FMH::MODEL_KEY>(role)];

    if(oldValue == value.toString())
        return false;

    this->notes[index].insert(static_cast<FMH::MODEL_KEY>(role), value.toString());

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
        if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
        {
            newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
            roles << FMH::MODEL_NAME_KEY[key];
        }

    this->notes[index] = newData;

    if(this->update(newData))
    {
        emit this->updateModel(index, roles);
        return true;
    }

    return false;
}

bool Notes::update(const FMH::MODEL &note)
{
    auto id = note[FMH::MODEL_KEY::ID];
    auto title = note[FMH::MODEL_KEY::TITLE];
    auto content = note[FMH::MODEL_KEY::CONTENT];
    auto color = note[FMH::MODEL_KEY::COLOR];
    auto pin = note[FMH::MODEL_KEY::PIN].toInt();
    auto favorite = note[FMH::MODEL_KEY::FAVORITE].toInt();
    auto tags = note[FMH::MODEL_KEY::TAG].split(",", QString::SkipEmptyParts);
    auto modified =note[FMH::MODEL_KEY::MODIFIED];

    QVariantMap note_map =
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::CONTENT], content},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], color},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::PIN], pin},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAVORITE], favorite},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MODIFIED], modified}
    };

    for(auto tg : tags)
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id, color);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map, {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}} );
}

bool Notes::remove(const int &index)
{
    emit this->preItemRemoved(index);
    auto id = this->notes.at(index)[FMH::MODEL_KEY::ID];
    QVariantMap note = {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}};

    if(this->db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], note))
    {
        this->notes.removeAt(index);
        emit this->postItemRemoved();
        return true;
    }

    return false;
}

void Notes::setAccount(const QVariantMap &account)
{
    this->m_account = account;
    const auto data = FM::toModel(this->m_account);
    syncer->setCredentials(data[FMH::MODEL_KEY::USER], data[FMH::MODEL_KEY::PASSWORD], QUrl(data[FMH::MODEL_KEY::SERVER]).host());
    syncer->getNotes();
    emit accountChanged();
}

QVariantMap Notes::getAccount() const
{
    return this->m_account;
}

QVariantList Notes::getTags(const int &index)
{
    if(index < 0 || index >= this->notes.size())
        return QVariantList();

    auto id = this->notes.at(index)[FMH::MODEL_KEY::ID];
    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::NOTES], id);
}

QVariantMap Notes::get(const int &index) const
{
    if(index >= this->notes.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto note = this->notes.at(index);

    for(auto key : note.keys())
        res.insert(FMH::MODEL_NAME[key], note[key]);

    return res;
}
