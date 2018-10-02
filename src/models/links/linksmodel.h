#ifndef LINKSMODEL_H
#define LINKSMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "owl.h"

class Links;
class LinksModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit LinksModel(QObject *parent = nullptr);
    enum
    {
        title,
        body
    };
    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE QVariantMap get(const int &index);
    Q_INVOKABLE void sortBy(const int &index, const QString &order);
    Q_INVOKABLE bool insert(const QVariantMap &link);
    Q_INVOKABLE QVariantList getTags(const int &index);

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

private:
    Links *mLinks;
};

#endif // NOTESMODEL_H
