#ifndef NOTESMODEL_H
#define NOTESMODEL_H

#include <QAbstractListModel>
#include <QList>

class Notes;
class NotesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Notes *notes READ notes WRITE setNotes)
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
    Q_INVOKABLE QVariantMap get(const int index);
    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    Notes *notes() const;
    void setNotes(Notes *value);

private:
    Notes *mNotes;
};

#endif // NOTESMODEL_H
