#include "linker.h"
#include <QEventLoop>
#include <QWebFrame>

#include "utils/htmlparser.h"

Linker::Linker(QObject *parent) : QObject(parent)
{

}

/* extract needs to extract from a url the title, the body and a preview image*/
void Linker::extract(const QString &url)
{
    auto data = this->getUrl(url);
    htmlParser parser;
    parser.setHtml(data);
    qDebug()<<data;
    query(data, "title");
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

void Linker::query(QByteArray &array, QString qq)
{
    auto frame = new QWebPage(this);

    QWebSettings::setObjectCacheCapacities(0,0,0);
    frame->settings()->setAttribute(QWebSettings::LocalContentCanAccessFileUrls,false);
    frame->settings()->setAttribute(QWebSettings::LocalContentCanAccessRemoteUrls,false);

    connect(frame->mainFrame(), &QWebFrame::loadFinished, [qq, this](bool ok)
    {
       this->parsingWork(qq);
    });


    qDebug() << "Count Chars :: " << array.count();
    frame->mainFrame()->setHtml(array);

    doc = frame->mainFrame()->documentElement();

}

void Linker::parsingWork(QString query)
{
    qDebug() << "Start parsing content .....";

    QWebElementCollection linkCollection = doc.findAll(query);
    qDebug() << "Found " << linkCollection.count() << " links";

    foreach (QWebElement link, linkCollection)
    {
        qDebug() << "found link " << link.toPlainText();
    }

    qDebug() << "stop parsing content .....";
}
