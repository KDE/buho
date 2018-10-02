#ifndef NOTESMODEL_H
#define NOTESMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "owl.h"

class Notes;
class NotesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit NotesModel(QObject *parent = nullptr);
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
    Q_INVOKABLE bool insert(const QVariantMap &note);

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    friend bool operator<(const OWL::DB & m1, const OWL::DB & m2)
    {
        return m1[OWL::KEY::TITLE] < m2[OWL::KEY::TITLE];
    }

private:
    Notes *mNotes;
};

#endif // NOTESMODEL_H
