#pragma once

#include <QObject>
#include <syncer.h>

#include <MauiKit4/Core/fmh.h>

/**
 * @brief The Syncer class
 * This interfaces between local storage and cloud
 * Its work is to try and keep thing synced and do the background work on updating notes
 * from local to cloud and viceversa.
 * This interface should be used to handle the whol offline and online work,
 * instead of manually inserting to the db or the cloud providers
 */

class DB;
class NotesController;
class Tagging;
class NotesSyncer : public Syncer
{
    Q_OBJECT

public:
    explicit NotesSyncer(QObject *parent = nullptr);
    //// NOTES INTERFACES
    /// interfaces with the the notes from both, local and remote

    /**
     * @brief insertNote
     * saves a new note online and offline
     * The signal Syncer::noteInserted(FMH::MODEL, STATE) is emitted,
     * indicating the created note and the transaction resulting state
     * @param note
     * the note to be stored represented by FMH::MODEL
     */
    void insertNote(FMH::MODEL &note);

    /**
     * @brief updateNote
     * Update online and offline an existing note.
     * The signal Syncer::noteUpdated(FMH::MODEL, STATE) is emitted,
     * indicating the updated note and the transaction resulting state
     * @param id
     * ID of the existing note
     * @param note
     * the new note contents represented by FMH::MODEL
     */
    void updateNote(QString id, FMH::MODEL &note);

    /**
     * @brief removeNote
     * remove a note from online and offline storage
     * The signal Syncer::noteRemoved(FMH::MODEL, STATE) is emitted,
     * indicating the removed note and the transaction resulting state
     * @param id
     * ID of the exisiting  note
     */
    void removeNote(const QString &id);

    /**
     * @brief getNote
     * Retrieves an existing note, whether the note is located offline or online.
     * When the note is ready the signal Syncer::noteReady(FMH::MODEL) is emitted
     * @param id
     * ID of the exisiting  note
     */
    void getNote(const QString &id);

    /**
     * @brief getNotes
     * Retrieves all the notes, online and offline notes.
     * When the notes are ready the signal Syncer::notesReady(FMH::MODEL_LIST) is emitted.
     */
    void getNotes();
    void getLocalNotes();
    void getRemoteNotes();

private:
    /**
     * @brief tag
     * Instance of the Maui project tag-ger. It adds tags to the abtract notes
     * For online tagging one could use the categories ?
     */
    Tagging *tag;

    /**
     * @brief db
     * Instance to the data base storing the notes information and location,
     * offline and online.
     */
    DB *db;

    NotesController *m_notesController;
    /**
     * @brief syncNote
     * Has the job to sync a note between the offline and online versions
     * @param id
     * ID of the note to be synced
     */
    void syncNote(const QString &id);

    static const QString noteIdFromStamp(const QString &provider, const QString &stamp);
    static const QString noteStampFromId(const QString &id);

    void setConections() override final;

Q_SIGNALS:
    // FOR NOTES
    void noteInserted(FMH::MODEL note, STATE state);
    void noteUpdated(FMH::MODEL note, STATE state);
    void noteRemoved(FMH::MODEL note, STATE state);
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);

};
