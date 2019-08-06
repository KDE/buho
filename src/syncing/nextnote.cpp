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

QString NextNote::API = "https://PROVIDER/index.php/apps/notes/api/v0.2/";

NextNote::NextNote(QObject *parent) : AbstractNotesSyncer(parent)
{

}

NextNote::~NextNote()
{
}

void NextNote::getNote(const QString &id) const
{
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

void NextNote::insertNote(const FMH::MODEL &note) const
{
}

void NextNote::updateNote(const QString &id, const FMH::MODEL &note) const
{
}

void NextNote::removeNote(const QString &id) const
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


