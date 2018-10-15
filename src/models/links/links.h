#ifndef LINKS_H
#define LINKS_H

#include <QObject>
#include "./../baselist.h"

class DB;
class Tagging;

class Links : public BaseList
{
    Q_OBJECT

public:
    explicit Links(QObject *parent = nullptr);
    OWL::DB_LIST items() const override;

private:
    Tagging *tag;
    DB *db;
    OWL::DB_LIST links;

signals:

public slots:
    void sortBy(const int &role, const QString &order = "DESC") override;
    QVariantMap get(const int &index) const override;
    bool insert(const QVariantMap &link) override;
    bool update(const int &index, const QVariant &value, const int &role) override; //deprecrated
    bool update(const QVariantMap &data, const int &index);
    bool update(const OWL::DB &link) override;
    bool remove(const int &index) override;

    QVariantList getTags(const int &index);

};

#endif // NOTES_H
