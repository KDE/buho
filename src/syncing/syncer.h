#ifndef SYNCER_H
#define SYNCER_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif
/**
 * @brief The Syncer class
 * This interfaces between local storage and cloud
 * Its work is to try and keep thing synced and do the background work on updating notes
 * from local to cloud and viceversa.
 * This interface should be used to handle the whol offline and online work,
 * instead of manually inserting to the db or the cloud providers
 */

struct STATE
{
    enum TYPE : uint
    {
        LOCAL,
        REMOTE
    };

    enum STATUS : uint
    {
        OK,
        ERROR
    };

    TYPE type;
    STATUS status;
    QString msg = QString();
};

class DB;
class AbstractNotesProvider;
class Tagging;
class Syncer: public QObject
{
    Q_OBJECT

public:
    explicit Syncer(QObject *parent = nullptr);

    /**
     * @brief setProviderAccount
     * sets the credentials to the current account
     * for the current provider being used
     * @param account
     * the account data represented by FMH::MODEL
     * where the valid keys are:
     * FMH::MODEL_KEY::USER user name
     * FMH::MODEL_KEY::PASSWORD users password
     * FMH::MODEL_KEY::PROVIDER the url to the provider server
     */
    void setAccount(const FMH::MODEL &account);

    /**
     * @brief setProvider
     * sets the provider interface
     * this allows to change the provider source
     * @param provider
     * the provider must inherit the asbtract class AbstractNotesProvider.
     * The value passed is then moved to this class private property Syncer::provider
     */
    void setProvider(AbstractNotesProvider *provider);
    /**
     * @brief insertNote
     * saves a new note online and offline
     * The signal noteInserted(FMH::MODEL, STATE) is emitted,
     * indicating the created note and the transaction resulting state
     * @param note
     * the note to be stored represented by FMH::MODEL
     */
    void insertNote(FMH::MODEL &note);

    /**
     * @brief updateNote
     * Update online and offline an existing note.
     * The signal noteUpdated(FMH::MODEL, STATE) is emitted,
     * indicating the updated note and the transaction resulting state
     * @param id
     * ID of the existing note
     * @param note
     * the new note contents represented by FMH::MODEL
     */
    void updateNote(const QString &id, const FMH::MODEL &note);

    /**
     * @brief removeNote
     * remove a note from online and offline storage
     * The signal noteRemoved(FMH::MODEL, STATE) is emitted,
     * indicating the removed note and the transaction resulting state
     * @param id
     * ID of the exisiting  note
     */
    void removeNote(const QString &id);

    /**
     * @brief getNote
     * Retrieves an existing note, whether the note is located offline or online.
     * When the note is ready the signal noteReady(FMH::MODEL) is emitted
     * @param id
     * ID of the exisiting  note
     */
    void getNote(const QString &id);

    /**
     * @brief getNotes
     * Retrieves all the notes, online and offline notes.
     * When the notes are ready the signal notesReady(FMH::MODEL_LIST) is emitted.
     */
    void getNotes();

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

    /**
     * @brief server
     * Abstract instance to the online server to perfom CRUD actions
     */
    AbstractNotesProvider *provider;

    /**
     * @brief syncNote
     * Has the job to sync a note between the offline and online versions
     * @param id
     * ID of the note to be synced
     */
    void syncNote(const QString &id);

    /**
     * @brief stampNote
     * Adds an stamp id to identify the note offline and online
     * @param note
     * the note model is passed by ref and a STAMP key value is inserted
     */
    static void stampNote(FMH::MODEL &note);

    static const QString idFromStamp(DB *_db, const QString &provider, const QString &stamp) ;
    static const QString stampFromId(DB *_db, const QString &id) ;

    void setConections();

protected:
    /**
     * @brief insertLocal
     * performs the insertion of a new note in the local storage
     * @param note
     * note to be inserted
     * @return bool
     * true if the note was inserted sucessfully in the local storage
     */
    bool insertLocal(FMH::MODEL &note);

    /**
     * @brief insertRemote
     * perfroms the insertion of a new note in the remote provider server
     * @param note
     * the note to be inserted
     */
    void insertRemote(FMH::MODEL &note);


    bool updateLocal(const QString &id, const FMH::MODEL &note);
    void updateRemote(const QString &id, const FMH::MODEL &note);

    bool removeLocal(const QString &id);
    void removeRemote(const QString &id);

signals:
    void noteInserted(FMH::MODEL note, STATE state);
    void noteUpdated(FMH::MODEL note, STATE state);
    void noteRemoved(FMH::MODEL note, STATE state);
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);

public slots:
};


#endif // SYNCER_H
