#include "syncer.h"
#include "db/db.h"
#include "nextnote.h"

#include <QUuid>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#endif

Syncer::Syncer(QObject *parent) : QObject(parent),
    tag(Tagging::getInstance()),
    db(DB::getInstance()),
    provider(new NextNote(this))
{

    connect(this->provider, &AbstractNotesProvider::noteInserted, [&](FMH::MODEL note)
    {
        qDebug()<< "STAMP OF THE NEWLY INSERTED NOTE" << note[FMH::MODEL_KEY::ID] << note;
        this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::ID,
                                                                                                    FMH::MODEL_KEY::STAMP,
                                                                                                    FMH::MODEL_KEY::USER,
                                                                                                    FMH::MODEL_KEY::SERVER})));
        emit this->noteInserted(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note inserted on server provider"});
    });

    connect(this->provider, &AbstractNotesProvider::notesReady, [&](FMH::MODEL_LIST notes)
    {
        //        qDebug()<< "SERVER NOETS READY "<< notes;

        //if there are no notes in the provider server, then just return
        if(notes.isEmpty())
            return;

        // there might be two case scenarios:
        // the note exists locally in the db, so it needs to be updated with the server version
        // the note does not exists locally, so it needs to be inserted into the db
        for(const auto &note : notes)
        {
            const auto id = Syncer::idFromStamp(this->db, this->provider->provider(), note[FMH::MODEL_KEY::ID]);

            // if the id is empty then the note does nto exists, so ithe note is inserted into the local db
            if(id.isEmpty())
            {
                //here insert the note into the db
                auto __note = FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                                        FMH::MODEL_KEY::CONTENT,
                                                        FMH::MODEL_KEY::FAVORITE,
                                                        FMH::MODEL_KEY::MODIFIED,
                                                        FMH::MODEL_KEY::ADDDATE});

                __note[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(note[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                __note[FMH::MODEL_KEY::ADDDATE] = __note[FMH::MODEL_KEY::MODIFIED];

                if(!this->insertLocal(__note))
                {
                    qWarning()<< "Remote note could not be inserted to the local storage";
                    continue;
                }

                __note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID];
                __note[FMH::MODEL_KEY::USER] = this->provider->user();
                __note[FMH::MODEL_KEY::SERVER] = this->provider->provider();


                this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(__note, {FMH::MODEL_KEY::ID,
                                                                                                              FMH::MODEL_KEY::STAMP,
                                                                                                              FMH::MODEL_KEY::USER,
                                                                                                              FMH::MODEL_KEY::SERVER})));

            }else
            {
                //the note exists in the db locally, so update it
                auto __note = FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                                        FMH::MODEL_KEY::CONTENT,
                                                        FMH::MODEL_KEY::MODIFIED,
                                                        FMH::MODEL_KEY::FAVORITE});
                __note[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(note[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                this->updateLocal(id, __note);
                emit this->noteInserted(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note inserted on local db, from the server provider"});
            }
        }

        emit this->notesReady(this->db->getDBData("select n.*, ns.server, ns.user, ns.stamp from notes n inner join notes_sync ns on n.id = ns.id "));
    });

    connect(this->provider, &AbstractNotesProvider::noteUpdated, [&](FMH::MODEL note)
    {
        const auto id = Syncer::idFromStamp(this->db, this->provider->provider(), note[FMH::MODEL_KEY::ID]);
        if(!note.isEmpty())
            this->updateLocal(id, FMH::filterModel(note, {FMH::MODEL_KEY::TITLE}));
        emit this->noteUpdated(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note updated on server provider"});
    });
}

void Syncer::setAccount(const FMH::MODEL &account)
{
    this->provider->setCredentials(account);
}

void Syncer::insertNote(FMH::MODEL &note)
{
    if(!this->insertLocal(note))
    {
        qWarning()<< "The note could not be inserted locally, "
                     "therefore it was not attempted to insert it to the remote provider server, "
                     "even if it existed.";
        return;
    }

    this->insertRemote(note);
    emit this->noteInserted(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note inserted on the DB locally"});
}

void Syncer::updateNote(const QString &id, const FMH::MODEL &note)
{
    if(!this->updateLocal(id, note))
    {
        qWarning()<< "The note could not be updated locally, "
                     "therefore it was not attempted to update it on the remote server provider, "
                     "even if it existed.";
        return;
    }

    //to update remote note we need to pass the stamp as the id
    const auto stamp = note[FMH::MODEL_KEY::STAMP];
    if(!stamp.isEmpty())
        this->updateRemote(stamp, note);

    emit this->noteUpdated(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note updated on the DB locally"});
}

void Syncer::getNotes()
{
    const auto notes = this->db->getDBData("select n.*, ns.server, ns.user, ns.stamp from notes n inner join notes_sync ns on n.id = ns.id ");

    if(this->provider->isValid())
        this->provider->getNotes();
    else {
        qWarning()<< "Credentials are missing to get notes";
    }

    emit this->notesReady(notes);
}

void Syncer::stampNote(FMH::MODEL &note)
{
    const auto id = QUuid::createUuid().toString();
    note[FMH::MODEL_KEY::ID] = id;
}


const QString Syncer::idFromStamp(DB *_db, const QString &provider, const QString &stamp)
{
    return [&]() -> QString {
        const auto data = _db->getDBData(QString("select id from notes_sync where server = '%1' AND stamp = '%2'").arg(provider, stamp));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::ID];
    }();
}

bool Syncer::insertLocal(FMH::MODEL &note)
{
    qDebug()<<"TAGS"<< note[FMH::MODEL_KEY::TAG];

    Syncer::stampNote(note); //adds a local id to the note
    const auto __noteMap = FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::ID,
                                                               FMH::MODEL_KEY::TITLE,
                                                               FMH::MODEL_KEY::CONTENT,
                                                               FMH::MODEL_KEY::COLOR,
                                                               FMH::MODEL_KEY::PIN,
                                                               FMH::MODEL_KEY::FAVORITE,
                                                               FMH::MODEL_KEY::MODIFIED,
                                                               FMH::MODEL_KEY::ADDDATE}));

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], __noteMap))
    {
        for(const auto &tg : note[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], note[FMH::MODEL_KEY::ID], note[FMH::MODEL_KEY::COLOR]);

        return true;
    }

    return false;
}

void Syncer::insertRemote(FMH::MODEL &note)
{
    if(this->provider->isValid())
        this->provider->insertNote(note);
}

bool Syncer::updateLocal(const QString &id, const FMH::MODEL &note)
{
    for(const auto &tg : note[FMH::MODEL_KEY::TAG])
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::NOTES],
            FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                                FMH::MODEL_KEY::CONTENT,
                                                FMH::MODEL_KEY::COLOR,
                                                FMH::MODEL_KEY::PIN,
                                                FMH::MODEL_KEY::MODIFIED,
                                                FMH::MODEL_KEY::FAVORITE})), QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
}

void Syncer::updateRemote(const QString &id, const FMH::MODEL &note)
{
    if(this->provider->isValid())
        this->provider->updateNote(id, note);
}
