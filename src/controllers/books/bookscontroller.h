#ifndef BOOKSCONTROLLER_H
#define BOOKSCONTROLLER_H

#include <QObject>

class BooksController : public QObject
{
    Q_OBJECT
public:
    explicit BooksController(QObject *parent = nullptr);

signals:

};

#endif // BOOKSCONTROLLER_H
