#ifndef BOOKS_H
#define BOOKS_H

#include <QObject>
#include "owl.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class Booklet;
class Syncer;
class Books : public MauiList
{
    Q_OBJECT

    Q_PROPERTY(SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)
    Q_PROPERTY(Booklet *booklet READ getBooklet NOTIFY bookletChanged CONSTANT FINAL)
    Q_PROPERTY(int currentBook READ getCurrentBook WRITE setCurrentBook NOTIFY currentBookChanged)


public:
    enum ORDER : uint8_t
    {
        DESC,
        ASC
    };
    Q_ENUM(ORDER)

    enum SORTBY : uint8_t
    {
        TITLE = FMH::MODEL_KEY::TITLE,
        ADDDATE = FMH::MODEL_KEY::ADDDATE,
        MODIFIED = FMH::MODEL_KEY::MODIFIED,
        COLOR = FMH::MODEL_KEY::COLOR,
        FAVORITE = FMH::MODEL_KEY::FAVORITE,
        PIN = FMH::MODEL_KEY::PIN
    };
    Q_ENUM(SORTBY)

    Books(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override final;

    void setSortBy(const SORTBY &sort);
    SORTBY getSortBy() const;
    void setOrder(const ORDER &order);
    ORDER getOrder() const;

    Booklet * getBooklet() const;

    int getCurrentBook() const;

private:
    Syncer *syncer;
    Booklet * m_booklet;

    FMH::MODEL_LIST m_list;

    void sortList();
    void openBook(const int &index);

    SORTBY sort = SORTBY::MODIFIED;
    ORDER order = ORDER::DESC;

    int m_currentBook;

signals:
    void sortByChanged();
    void orderChanged();

    void bookletChanged(Booklet * booklet);

    void currentBookChanged(int currentBook);

public slots:
    QVariantMap get(const int &index) const;

    /**
     * @brief insert
     * insertes a new book by using the syncer interface
     * @param note
     * @return
     */
    bool insert(const QVariantMap &book);
    bool update(const QVariantMap &data, const int &index);
    bool remove(const int &index);

    void setCurrentBook(int currentBook);
};

#endif // BOOKS_H
