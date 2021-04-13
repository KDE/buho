#include "notessyncer.h"
#include "controllers/notes/notescontroller.h"
#include "db/db.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/Core/mauiaccounts.h>
#include <MauiKit/FileBrowsing/tagging.h>

NotesSyncer::NotesSyncer(QObject *parent)
    : Syncer(parent)
    , tag(Tagging::getInstance())
    , db(DB::getInstance())
    , m_notesController(new NotesController(this)) // local handler for notes
{
    connect(MauiAccounts::instance(), &MauiAccounts::currentAccountChanged, [&](QVariantMap) {
        this->getRemoteNotes();
    });

    connect(this->m_notesController, &NotesController::noteReady, this, &NotesSyncer::noteReady);
}

void NotesSyncer::insertNote(FMH::MODEL &note)
{
    if (!this->m_notesController->insertNote(note))
        return;

    if (this->validProvider())
        this->getProvider().insertNote(note);

    emit this->noteInserted(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note saved locally"});
}

void NotesSyncer::updateNote(QString id, FMH::MODEL &note)
{
    if (!this->m_notesController->updateNote(note, id)) {
        qWarning() << "The note could not be updated locally, "
                      "therefore it was not attempted to update it on the remote server provider, "
                      "even if it existed.";
        return;
    }

    // to update remote note we need to pass the stamp as the id
    const auto stamp = NotesSyncer::noteStampFromId(id);
    if (!stamp.isEmpty()) {
        if (this->validProvider())
            this->getProvider().updateNote(stamp, note);
    }

    emit this->noteUpdated(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note updated on the DB locally"});
}

void NotesSyncer::removeNote(const QString &id)
{
    // to remove the remote note we need to pass the stamp as the id,
    // and before removing the note locally we need to retireved first

    const auto stamp = NotesSyncer::noteStampFromId(id);
    if (!this->m_notesController->removeNote(id)) {
        qWarning() << "The note could not be inserted locally, "
                      "therefore it was not attempted to insert it to the remote provider server, "
                      "even if it existed.";
        return;
    }

    if (!stamp.isEmpty()) {
        if (this->validProvider())
            this->getProvider().removeNote(stamp);
    }

    emit this->noteRemoved(FMH::MODEL(), {STATE::TYPE::LOCAL, STATE::STATUS::OK, "The note has been removed from the local DB"});
}

void NotesSyncer::getNotes()
{
    this->getLocalNotes();
    this->getRemoteNotes();
}

void NotesSyncer::getLocalNotes()
{
    this->m_notesController->getNotes();
}

void NotesSyncer::getRemoteNotes()
{
    if (this->validProvider())
        this->getProvider().getNotes();
    else
        qWarning() << "Failed to fetch online notes. Credentials are missing  or the provider has not been set";
}

const QString NotesSyncer::noteIdFromStamp(const QString &provider, const QString &stamp)
{
    return [&]() -> const QString {
        const auto data = DB::getInstance()->getDBData(QString("select id from notes_sync where server = '%1' AND stamp = '%2'").arg(provider, stamp));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::ID];
    }();
}

const QString NotesSyncer::noteStampFromId(const QString &id)
{
    return [&]() -> const QString {
        const auto data = DB::getInstance()->getDBData(QString("select stamp from notes_sync where id = '%1'").arg(id));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::STAMP];
    }();
}

void NotesSyncer::setConections()
{
    connect(&this->getProvider(), &AbstractNotesProvider::noteInserted, [&](FMH::MODEL note) {
        qDebug() << "STAMP ID OF THE NEWLY INSERTED NOTE" << note[FMH::MODEL_KEY::STAMP] << note;
        this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::ID, FMH::MODEL_KEY::STAMP, FMH::MODEL_KEY::USER, FMH::MODEL_KEY::SERVER})));
        emit this->noteInserted(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note inserted on the server provider"});
    });

    connect(&this->getProvider(), &AbstractNotesProvider::notesReady, [&](FMH::MODEL_LIST notes) {
        //        qDebug()<< "SERVER NOETS READY "<< notes;

        // if there are no notes in the provider server, then just return
        if (notes.isEmpty())
            return;

        // there might be two case scenarios:
        // the note exists locally in the db, so it needs to be updated with the server version
        // the note does not exists locally, so it needs to be inserted into the db
        for (auto &note : notes) {
            const auto id = NotesSyncer::noteIdFromStamp(this->getProvider().provider(), note[FMH::MODEL_KEY::STAMP]);
            note[FMH::MODEL_KEY::ID] = id;
            note[FMH::MODEL_KEY::FAVORITE] = note[FMH::MODEL_KEY::FAVORITE] == "true" ? "1" : "0";
            qDebug() << "REMOTE NOTE MAPPED ID" << id << note[FMH::MODEL_KEY::STAMP];

            // if the id is empty then the note does not exists, so the note is inserted locally
            if (id.isEmpty()) {
                if (!this->m_notesController->insertNote(note))
                    continue;

                this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::ID, FMH::MODEL_KEY::STAMP, FMH::MODEL_KEY::USER, FMH::MODEL_KEY::SERVER})));
                emit this->noteInserted(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note inserted on local db, from the server provider"});

            } else {
                // the note does exists locally, so update it
                note[FMH::MODEL_KEY::URL] = [&]() -> const QString {
                    const auto data = DB::getInstance()->getDBData(QString("select url from notes where id = '%1'").arg(id));
                    return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL];
                }();

                auto remoteDate = QDateTime::fromSecsSinceEpoch(note[FMH::MODEL_KEY::MODIFIED].toInt());
                auto localDate = QFileInfo(QUrl(note[FMH::MODEL_KEY::URL]).toLocalFile()).lastModified();

                qDebug() << "UPDATING FROM REMOTE" << note[FMH::MODEL_KEY::URL] << localDate.secsTo(QDateTime::currentDateTime()) << remoteDate.secsTo(QDateTime::currentDateTime());

                if (remoteDate <= localDate)
                    continue;

                if (!this->m_notesController->updateNote(note, id))
                    continue;

                emit this->noteUpdated(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note updated on local db, from the server provider"});
            }
        }
    });

    connect(&this->getProvider(), &AbstractNotesProvider::noteUpdated, [&](FMH::MODEL note) {
        const auto id = NotesSyncer::noteIdFromStamp(this->getProvider().provider(), note[FMH::MODEL_KEY::STAMP]);
        note[FMH::MODEL_KEY::ID] = id;

        if (!note.isEmpty())
            this->m_notesController->updateNote(note, id);
        emit this->noteUpdated(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note updated on server provider"});
    });

    connect(&this->getProvider(), &AbstractNotesProvider::noteRemoved, [&]() {
        emit this->noteRemoved(FMH::MODEL(), {STATE::TYPE::REMOTE, STATE::STATUS::OK, "The note has been removed from the remove server provider"});
    });
}
