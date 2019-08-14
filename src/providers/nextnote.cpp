#include "nextnote.h"
#include <QUrl>
#include <QDomDocument>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>

#ifdef STATIC_MAUIKIT
#include "fm.h"
#else
#include <MauiKit/fm.h>
#endif

const QString NextNote::API = "https://PROVIDER/index.php/apps/notes/api/v0.2/";

NextNote::NextNote(QObject *parent) : AbstractNotesProvider(parent)
{

}

NextNote::~NextNote()
{
}

void NextNote::getNote(const QString &id)
{
    auto url = QString(NextNote::API+"%1, %2").replace("PROVIDER", this->m_provider).arg("notes/", id);

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [&, downloader = std::move(downloader)](QByteArray array)
    {
        const auto notes = this->parseNotes(array);
        emit this->noteReady(notes.isEmpty() ? FMH::MODEL() : notes.first());
        downloader->deleteLater();
    });

    downloader->getArray(url, header);
}

void NextNote::sendNotes(QByteArray array)
{
    //    emit this->notesReady(notes);
}

void NextNote::getNotes()
{
    //https://milo.h@aol.com:Corazon1corazon@free01.thegood.cloud/index.php/apps/notes/api/v0.2/notes
    auto url = NextNote::formatUrl(this->m_user, this->m_password, this->m_provider)+"notes";

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [&, downloader = std::move(downloader)](QByteArray array)
    {
        emit this->notesReady(this->parseNotes(array));
        downloader->deleteLater();
    });

    downloader->getArray(url, header);
}

void NextNote::insertNote(const FMH::MODEL &note)
{
    QByteArray payload=QJsonDocument::fromVariant(FM::toMap(note)).toJson();
    qDebug() << "UPLOADING NEW NOT" << QVariant(payload).toString();

    const auto url = QString(NextNote::API+"%1").replace("PROVIDER", this->m_provider).arg("notes");

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QVariantMap headers
    {
        {"Authorization", headerData.toLocal8Bit()},
        {QString::number(QNetworkRequest::ContentTypeHeader),"application/json"}
    };

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,"application/json");
    request.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());

    QNetworkAccessManager *restclient; //in class
    restclient = new QNetworkAccessManager(this); //constructor
    QNetworkReply *reply = restclient->post(request,payload);

    connect(reply, &QNetworkReply::finished, [=]()
    {
        qDebug() << "Note insertyion finished?";
        const auto notes = this->parseNotes(reply->readAll());
        emit this->noteInserted(notes.isEmpty() ? FMH::MODEL() : notes.first());
        reply->deleteLater();
    });
}

void NextNote::updateNote(const QString &id, const FMH::MODEL &note)
{
}

void NextNote::removeNote(const QString &id)
{
}

QString NextNote::formatUrl(const QString &user, const QString &password, const QString &provider)
{
    auto url = NextNote::API;
    url.replace("USER", user);
    url.replace("PASSWORD", password);
    url.replace("PROVIDER", provider);
    return url;
}

FMH::MODEL_LIST NextNote::parseNotes(const QByteArray &array)
{
    FMH::MODEL_LIST res;
    qDebug()<< "trying to parse notes" << array;
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError)
    {
        qDebug()<< "ERROR PARSING";
        return res;
    }

    auto notes = jsonResponse.toVariant();
    for(const auto &map : notes.toList())
    {
        res << FM::toModel(map.toMap());
    }

    return res;
}


