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

    Q_INVOKABLE bool insertLink(const QVariantMap &link);
    bool updateLink(const int &index, const QVariant &value, const int &role);
    bool updateLink(const OWL::DB &link);
    Q_INVOKABLE bool removeLink(const QVariantMap &link);

    Q_INVOKABLE QVariantList getLinkTags(const QString &link);
private:
    Tagging *tag;
    DB *db;
    OWL::DB_LIST links;

signals:

public slots:

};

#endif // NOTES_H
