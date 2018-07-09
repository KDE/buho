#ifndef LINKER_H
#define LINKER_H

#include <QObject>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QWebPage>
#include <QWebElementCollection>

typedef QVariantMap LINK;

class Linker : public QObject
{
    Q_OBJECT
public:
    explicit Linker(QObject *parent = nullptr);

    Q_INVOKABLE void extract(const QString &url);

private:
    QByteArray getUrl(const QString &url);
    void query(QByteArray &array, QString qq);
    QWebElement doc;

signals:
    void previewReady(LINK data);

public slots:
    void parsingWork(QString query);

};

#endif // LINKER_H
