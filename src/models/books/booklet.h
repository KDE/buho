#ifndef BOOKLET_H
#define BOOKLET_H
#include "owl.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class Syncer;
class Booklet : public MauiList
{
    Q_OBJECT

    Q_PROPERTY(SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)
    Q_PROPERTY(QString book READ getBook WRITE setBook NOTIFY bookChanged)

public:
    Booklet(Syncer *syncer = nullptr, QObject *parent = nullptr);

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

    FMH::MODEL_LIST items() const override final;

    void setSortBy(const SORTBY &sort);
    SORTBY getSortBy() const;
    void setOrder(const ORDER &order);
    ORDER getOrder() const;

    QString getBook() const
    {
        return m_book;
    }

public slots:
    void setBook(QString book)
    {
        if (m_book == book)
            return;

        m_book = book;
        emit bookChanged(m_book);
    }

    void insert(const QVariantMap &data);
    void update(const QVariantMap &data, const int &index);
    void remove(const int &index);

private:
    FMH::MODEL_LIST m_list;
    Syncer *syncer;

    void sortList();

    SORTBY sort = SORTBY::MODIFIED;
    ORDER order = ORDER::DESC;

    QString m_book;

signals:
    void sortByChanged();
    void orderChanged();
    void bookChanged(QString book);
};

#endif // BOOKLET_H
