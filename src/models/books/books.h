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

class Syncer;
class Books : public MauiList
{
    Q_OBJECT

    Q_PROPERTY(SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)

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

private:
    Syncer *syncer;

    FMH::MODEL_LIST m_list;

    void sortList();

    SORTBY sort = SORTBY::MODIFIED;
    ORDER order = ORDER::DESC;

signals:
    void sortByChanged();
    void orderChanged();

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
};

#endif // BOOKS_H
