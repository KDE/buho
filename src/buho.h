#ifndef BUHO_H
#define BUHO_H

#include <QObject>
#include "db/dbactions.h"
#include "tagging.h"

class Buho : public DBActions
{
    Q_OBJECT
public:
    explicit Buho(QObject *parent = nullptr);
    Tagging* getTagging();
    Q_INVOKABLE bool openLink(const QString &url);

private:
    void setFolders();

signals:

public slots:
};

#endif // BUHO_H
