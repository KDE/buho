#ifndef LINKER_H
#define LINKER_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include "qgumbodocument.h"
#include "qgumbonode.h"

typedef QVariantMap LINK;

class Linker : public QObject
{
    Q_OBJECT
public:
    explicit Linker(QObject *parent = nullptr);

    Q_INVOKABLE void extract(const QString &url);

private:
    QByteArray getUrl(const QString &url);
    QStringList query(const QByteArray &array, const HtmlTag &tag, const QString &attribute = QString());

signals:
    void previewReady(QVariantMap link);

public slots:

};

#endif // LINKER_H
