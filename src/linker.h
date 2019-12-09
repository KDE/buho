#ifndef LINKER_H
#define LINKER_H

#include <QObject>

//#include "qgumbodocument.h"
//#include "qgumbonode.h"
#include <QVariantMap>

typedef QVariantMap LINK;

class Linker : public QObject
{
    Q_OBJECT
public:
    explicit Linker(QObject *parent = nullptr);
    static QByteArray getUrl(const QString &url);

    Q_INVOKABLE void extract(const QString &url);

private:
    QStringList query(const QByteArray &array, const QString &tag, const QString &attribute = QString());

signals:
    void previewReady(QVariantMap link);

public slots:

};

#endif // LINKER_H
