#include "linker.h"
#include <QEventLoop>

#include "qgumbodocument.h"
#include "qgumbonode.h"
#include "utils/htmlparser.h"

Linker::Linker(QObject *parent) : QObject(parent)
{

}

/* extract needs to extract from a url the title, the body and a preview image*/
void Linker::extract(const QString &url)
{
    auto data = this->getUrl(url);
    qDebug()<< query(data, "title");
}

QByteArray Linker::getUrl(const QString &url)
{
    QUrl mURL(url);
    QNetworkAccessManager manager;
    QNetworkRequest request (mURL);

    QNetworkReply *reply =  manager.get(request);
    QEventLoop loop;
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop,
            SLOT(quit()));

    loop.exec();

    if(reply->error())
    {
        qDebug() << reply->error();
        return QByteArray();
    }

    if(reply->bytesAvailable())
    {
        auto data = reply->readAll();
        reply->deleteLater();

        return data;
    }

    return QByteArray();
}

QString Linker::query(const QByteArray &array,const HtmlTag &tag)
{
    auto doc = QGumboDocument::parse(array);
    auto root = doc.rootNode();
    auto nodes = root.getElementsByTagName(tag);
    Q_ASSERT(nodes.size() == 1);

    auto title = nodes.front();
    return title.innerText();
}
