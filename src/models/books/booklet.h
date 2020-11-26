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

class BooksSyncer;
class Booklet : public MauiList
{
    Q_OBJECT

    Q_PROPERTY(SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)
    Q_PROPERTY(QString book READ getBook NOTIFY bookChanged)
    Q_PROPERTY(QString bookTitle READ getBookTitle NOTIFY bookTitleChanged)

public:
    Booklet(BooksSyncer *_syncer = nullptr, QObject *parent = nullptr);

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

    const FMH::MODEL_LIST &items() const override final;

    void setSortBy(const SORTBY &sort);
    SORTBY getSortBy() const;
    void setOrder(const ORDER &order);
    ORDER getOrder() const;

    QString getBook() const;
    void setBook(const QString &book);

    void setBookTitle(const QString &title);
    QString getBookTitle() const
    {
        return m_bookTitle;
    }

public slots:
    QVariantMap get(const int &index) const;
    void insert(const QVariantMap &data);
    void update(const QVariantMap &data, const int &index);
    void remove(const int &index);
    void clear();

private:
    FMH::MODEL_LIST m_list;
    BooksSyncer *syncer;

    void sortList();
    void appendBooklet(FMH::MODEL booklet);

    SORTBY sort = SORTBY::MODIFIED;
    ORDER order = ORDER::DESC;

    QString m_book;
    QString m_bookTitle;

signals:
    void sortByChanged();
    void orderChanged();
    void bookChanged(QString book);
    void bookTitleChanged(QString bookTitle);
};

#endif // BOOKLET_H
