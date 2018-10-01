#ifndef NOTES_H
#define NOTES_H

#include <QObject>
#include "db/db.h"

class Tagging;
class Notes : public DB
{
    Q_OBJECT

public:

    explicit Notes(QObject *parent = nullptr);

    OWL::DB_LIST items() const;
    bool insertNote(const QVariantMap &note);
    bool updateNote(const int &index, const QVariant &value, const int &role);
    bool updateNote(const OWL::DB &note);
    bool removeNote(const QVariantMap &note);
    QVariantList getNoteTags(const QString &id);

private:
    Tagging *tag;
    OWL::DB_LIST notes;
    OWL::DB_LIST getNotes();

signals:
    void noteInserted(QVariantMap note);

    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();

public slots:
    void appendItem();
    void removeItem();
};

#endif // NOTES_H
