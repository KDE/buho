#ifndef BUHO_H
#define BUHO_H

#include <QObject>

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
