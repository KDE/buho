#include "linker.h"
#include "owl.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QUrl>
#include <QEventLoop>

Linker::Linker(QObject *parent) : QObject(parent)
{

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
/* extract needs to extract from a url the title, the body and a preview image*/
void Linker::extract(const QString &url)
{
    auto data = getUrl(url);

    QString title = url;
    auto titles = query(data, HtmlTag::TITLE);

    if(!titles.isEmpty())
        title = titles[0];

    title = title.isEmpty() ? url : title;

    QStringList imgs;

    //    auto tags = query(data, HtmlTag::META);

    for(auto img : query(data, HtmlTag::IMG, "src"))
    {
        if(imgs.contains(img) || img.isEmpty()) continue;

        qDebug()<< "IMGAE URL" << img;
        if((img.startsWith("http") || img.startsWith("https"))
                && (img.endsWith(".png", Qt::CaseInsensitive) ||
                    img.endsWith(".jpg", Qt::CaseInsensitive) ||
                    img.endsWith(".gif", Qt::CaseInsensitive) ||
                    img.endsWith(".jpeg", Qt::CaseInsensitive)))

            imgs << img;
        else continue;
    }

    LINK link_data {{OWL::KEYMAP[OWL::KEY::TITLE], title.trimmed()},
                    {OWL::KEYMAP[OWL::KEY::BODY], data},
                    {OWL::KEYMAP[OWL::KEY::IMAGE], imgs}};
    emit previewReady(link_data);
}



QStringList Linker::query(const QByteArray &array, const HtmlTag &tag, const QString &attribute)
{
    QStringList res;
    auto doc = QGumboDocument::parse(array);
    auto root = doc.rootNode();

    auto node = root.getElementsByTagName(tag);

    for(const auto &i : node)
    {
        if(attribute.isEmpty())
            res << i.innerText();
        else res << i.getAttribute(attribute);
    }

    return res;
}

