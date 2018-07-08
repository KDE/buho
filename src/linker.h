#ifndef LINKER_H
#define LINKER_H

#include <QObject>

class linker : public QObject
{
    Q_OBJECT
public:
    explicit linker(QObject *parent = nullptr);

signals:

public slots:
};

#endif // LINKER_H