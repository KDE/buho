#ifndef BASELIST_H
#define BASELIST_H

#include <QObject>
#include "owl.h"

class BaseList : public QObject
{
    Q_OBJECT

    Q_PROPERTY(OWL::KEY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)
    Q_PROPERTY(ORDER order READ getOrder WRITE setOrder NOTIFY orderChanged)

public:
    explicit BaseList(QObject *parent = nullptr);
    enum ORDER : uint8_t
    {
        DESC,
        ASC
    };
    Q_ENUM(ORDER)
    Q_ENUM(OWL::KEY)

    //* To be overrided *//
    virtual OWL::DB_LIST items() const {return OWL::DB_LIST({{}});}

    virtual void setSortBy(const OWL::KEY &sort)
    {
        if(this->sort == sort)
            return;

        this->sort = sort;
        emit this->sortByChanged();
    }

    virtual OWL::KEY getSortBy() const
    {
        return this->sort;
    }

    virtual void setOrder(const ORDER &order)
    {
        if(this->order == order)
            return;

        this->order = order;
        emit this->orderChanged();
    }

    virtual ORDER getOrder() const
    {
        return this->order;
    }

protected:
    OWL::KEY sort = OWL::KEY::UPDATED;
    ORDER order = ORDER::DESC;

signals:
    void orderChanged();
    void sortByChanged();

    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void updateModel(int index, QVector<int> roles);
    void preListChanged();
    void postListChanged();

public slots:
    virtual QVariantMap get(const int &index) const
    {
        Q_UNUSED(index);
        return QVariantMap();
    }

    virtual bool update(const int &index, const QVariant &value, const int &role)
    {
        Q_UNUSED(index);
        Q_UNUSED(value);
        Q_UNUSED(role);
        return false;
    }

    virtual bool update(const QVariantMap &data, const int &index)
    {
        Q_UNUSED(index);
        Q_UNUSED(data);
        return false;
    }

    virtual bool update(const OWL::DB &data)
    {
        Q_UNUSED(data);
        return false;
    }

    virtual bool insert(const QVariantMap &map)
    {
        Q_UNUSED(map);
        return false;
    }

    virtual bool remove(const int &index)
    {
        Q_UNUSED(index);
        return false;
    }
};

#endif // BASELIST_H
