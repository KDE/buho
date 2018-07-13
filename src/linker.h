#ifndef LINKER_H
#define LINKER_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>

typedef QVariantMap LINK;

class Linker : public QObject
{
    Q_OBJECT
public:
    explicit Linker(QObject *parent = nullptr);

    Q_INVOKABLE void extract(const QString &url);

private:
    QByteArray getUrl(const QString &url);
    QString query(const QByteArray &array, const QString &qq);

signals:
    void previewReady(LINK data);

public slots:

};

#endif // LINKER_H
