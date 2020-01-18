#ifndef BOOKSCONTROLLER_H
#define BOOKSCONTROLLER_H

#include <QObject>
#include<QUuid>
#include "owl.h"

class DB;
class BooksController : public QObject
{
    Q_OBJECT
public:
    explicit BooksController(QObject *parent = nullptr);

    void getBooklet(const QString &bookId);
    bool insertBooklet(QString bookId, FMH::MODEL &booklet);
    bool updateBooklet(FMH::MODEL &booklet, QString id);
    bool removeBooklet(const QString &id);

    void getBooks();
    void getBooklets(const QString &book);

    bool insertBook(FMH::MODEL &book);
    bool updateBook(const QString &id, const FMH::MODEL &book);
    bool removeBook(const QString &id);
    bool getBook(const QString &id);

private:
    DB *m_db;

signals:
    void bookletReady(FMH::MODEL note);
    void bookletsReady(FMH::MODEL_LIST notes);
    void bookletInserted(FMH::MODEL note);
    void bookletUpdated(FMH::MODEL booklet);
    void bookletRemoved(FMH::MODEL booklet);

    void bookInserted(FMH::MODEL book);
    void bookUpdated(FMH::MODEL book);
    void bookRemoved(FMH::MODEL book);
    void bookReady(FMH::MODEL book);
    void booksReady(FMH::MODEL_LIST books);

};

#endif // BOOKSCONTROLLER_H
