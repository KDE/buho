#ifndef BUHO_H
#define BUHO_H

#include <QObject>
#include "db/dbactions.h"

class Buho : public DBActions
{
    Q_OBJECT
public:
    explicit Buho(QObject *parent = nullptr);

private:
    void setFolders();

signals:

public slots:
};

#endif // BUHO_H
