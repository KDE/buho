#ifndef NOTES_H
#define NOTES_H

#include <QObject>
#include "./../baselist.h"
#include "owl.h"

class DB;
class Tagging;
class Notes : public BaseList
{
    Q_OBJECT
public:
    explicit Notes(QObject *parent = nullptr);
    OWL::DB_LIST items() const override;

private:
    Tagging *tag;
    DB *db;
    OWL::DB_LIST notes;
    void sortList();

signals:

public slots:
    QVariantList getTags(const int &index);

    QVariantMap get(const int &index) const override;
    bool insert(const QVariantMap &note) override;
    bool update(const int &index, const QVariant &value, const int &role) override; //deprecrated
    bool update(const QVariantMap &data, const int &index) override;
    bool update(const OWL::DB &note) override;
    bool remove(const int &index) override;
};

#endif // NOTES_H
