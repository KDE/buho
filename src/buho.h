#ifndef BUHO_H
#define BUHO_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

class Buho : public QObject
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
