#ifndef BOOKSSYNCER_H
#define BOOKSSYNCER_H

#include <QObject>
#include <syncer.h>

class DB;
class BooksController;
class Tagging;
class BooksSyncer : public Syncer
{
    Q_OBJECT
public:
    explicit BooksSyncer(QObject *parent = nullptr);

    ////BOOKS & BOOKLET INTERFACES
    /// interfaces with the the books and booklets from both, local and remote

    /**
     * @brief getBooks
     * Retrieves all the books, online and offline.
     * When the books are ready the signal Syncer::booksReady(FMH::MODEL_LIST) is emitted
     */
    void getBooks();
    void getRemoteBooks();
    void getLocalBooks();

    void getBooklet(const QString &id);
    void getBooklets(const QString &book);

    void insertBooklet(const QString &bookId, FMH::MODEL &booklet);
    void updateBooklet(const QString &id, const QString &bookId, FMH::MODEL &booklet);
    void removeBooklet(const QString &id);


    void insertBook(FMH::MODEL &book);
    void updateBook(const QString &id, const FMH::MODEL &book);
    void removeBook(const QString &id);
    void getBook(const QString &id);

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

    BooksController *m_booksController;

    static const QString bookletIdFromStamp(const QString &provider, const QString &stamp) ;
    static const QString bookletStampFromId(const QString &id);
    void setConections() override final;
     const FMH::MODEL_LIST collectAllBooks();

signals:
    //FOR BOOKS
    void bookInserted(FMH::MODEL book, STATE state);
    void bookUpdated(FMH::MODEL book, STATE state);
    void bookRemoved(FMH::MODEL book, STATE state);
    void bookReady(FMH::MODEL book);
    void booksReady(FMH::MODEL_LIST books);

    //FOR BOOKLETS
    void bookletInserted(FMH::MODEL booklet, STATE state);
    void bookletUpdated(FMH::MODEL booklet, STATE state);
    void bookletRemoved(FMH::MODEL booklet, STATE state);
    void bookletReady(FMH::MODEL booklet);
};

#endif // BOOKSSYNCER_H
