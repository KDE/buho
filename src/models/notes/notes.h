#ifndef NOTES_H
#define NOTES_H

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
class Notes : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)
    Q_PROPERTY(QVariantMap account READ getAccount WRITE setAccount NOTIFY accountChanged)

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

    explicit Notes(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override final;

    void setSortBy(const SORTBY &sort);
    SORTBY getSortBy() const;
    void setOrder(const ORDER &order);
    ORDER getOrder() const;

    void setAccount(const QVariantMap &account);
    QVariantMap getAccount() const;

private:
    Syncer *syncer;

    FMH::MODEL_LIST notes;
    QVariantMap m_account;

    void sortList();

    SORTBY sort = SORTBY::MODIFIED;
    ORDER order = ORDER::DESC;

signals:
    void orderChanged();
    void sortByChanged();
    void accountChanged();

public slots:
    QVariantList getTags(const int &index);

    QVariantMap get(const int &index) const;
    bool insert(const QVariantMap &note);
    bool update(const QVariantMap &data, const int &index);
    bool remove(const int &index);

};

#endif // NOTES_H
