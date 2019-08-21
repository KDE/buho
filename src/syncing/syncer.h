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
    void updateNote(const QString &id, const FMH::MODEL &note);

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

    ////BOOKS & BOOKLET INTERFACES
    /// interfaces with the the books and booklets from both, local and remote

    /**
     * @brief getBooks
     * Retrieves all the books, online and offline.
     * When the books are ready the signal Syncer::booksReady(FMH::MODEL_LIST) is emitted
     */
    void getBooks();

    /**
     * @brief getBook
     * @param id
     */
    void getBook(const QString &id);

    /**
     * @brief insertBook
     * @param book
     */
    void insertBook(FMH::MODEL &book);

    /**
     * @brief updateBook
     * @param id
     * @param book
     */
    void updateBook(const QString &id, const FMH::MODEL &book);

    /**
     * @brief removeBook
     * @param id
     */
    void removeBook(const QString &id);

    //BOOKLETS INTERFACES

    /**
     * @brief getBooklet
     * @param id
     */
    void getBooklet(const QString &id);

    /**
     * @brief updateBooklet
     * @param id
     * @param booklet
     */
    void updateBooklet(const QString &id, FMH::MODEL &booklet);

    /**
     * @brief insertBooklet
     * @param booklet
     */
    void insertBooklet(const FMH::MODEL &booklet);

    /**
     * @brief removeBooklet
     * @param id
     */
    void removeBooklet(const QString &id);

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
    static void addId(FMH::MODEL &model);

    static const QString noteIdFromStamp(DB *_db, const QString &provider, const QString &stamp) ;
    static const QString noteStampFromId(DB *_db, const QString &id) ;

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
    bool insertNoteLocal(FMH::MODEL &note);

    /**
     * @brief insertRemote
     * perfroms the insertion of a new note in the remote provider server
     * @param note
     * the note to be inserted
     */
    void insertNoteRemote(FMH::MODEL &note);
    bool updateNoteLocal(const QString &id, const FMH::MODEL &note);
    void updateNoteRemote(const QString &id, const FMH::MODEL &note);
    bool removeNoteLocal(const QString &id);
    void removeNoteRemote(const QString &id);

    bool insertBookLocal(FMH::MODEL &book);
    void insertBookRemote(FMH::MODEL &book);
    bool updateBookLocal(const QString &id, const FMH::MODEL &book);
    void updateBookRemote(const QString &id, const FMH::MODEL &book);
    bool removeBookLocal(const QString &id);
    void removeBookRemote(const QString &id);

    bool insertBookletLocal(FMH::MODEL &booklet);
    void insertBookletRemote(FMH::MODEL &booklet);
    bool updateBookletLocal(const QString &id, const FMH::MODEL &booklet);
    void updateBookletRemote(const QString &id, const FMH::MODEL &booklet);
    bool removeBookletLocal(const QString &id);
    void removeBookletRemote(const QString &id);

    const FMH::MODEL_LIST collectAllNotes();
    const FMH::MODEL_LIST collectAllBooks();

    static inline const QUrl saveNoteFile(const FMH::MODEL &note);
    static inline const QString noteFileContent(const QUrl &path);

signals:
    //FOR NOTES
    void noteInserted(FMH::MODEL note, STATE state);
    void noteUpdated(FMH::MODEL note, STATE state);
    void noteRemoved(FMH::MODEL note, STATE state);
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);

    //FOR BOOKS
    void bookInserted(FMH::MODEL book, STATE state);
    void bookUpdated(FMH::MODEL book, STATE state);
    void bookRemoved(FMH::MODEL book, STATE state);
    void bookReady(FMH::MODEL book);
    void booksReady(FMH::MODEL_LIST books);


public slots:
};


#endif // SYNCER_H
