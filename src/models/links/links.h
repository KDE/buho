#ifndef NOTES_H
#define NOTES_H

#include <QObject>
#include "owl.h"

class DB;
class Tagging;

class Links : public QObject
{
    Q_OBJECT

public:

    explicit Links(QObject *parent = nullptr);
    OWL::DB_LIST items() const;

    void sortBy(const OWL::KEY &key, const QString &order = "DESC");


    bool insertNote(const QVariantMap &note);

    bool updateNote(const int &index, const QVariant &value, const int &role);
    bool updateNote(const OWL::DB &note);

    bool removeNote(const QVariantMap &note);
    QVariantList getNoteTags(const QString &id);

private:
    Tagging *tag;
    DB *db;
    OWL::DB_LIST notes;

signals:

public slots:

};

#endif // NOTES_H
