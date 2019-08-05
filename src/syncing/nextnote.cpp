#include "nextnote.h"

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

void NextNote::getNotes()
{
    //https://milo.h@aol.com:Corazon1corazon@free01.thegood.cloud/index.php/apps/notes/api/v0.2/notes
    auto url = NextNote::formatUrl(this->m_user, this->m_password, this->m_provider)+"notes";

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    this->request(url, header, [](QByteArray array)
    {
        qDebug()<< "GOT TEH NOTES" << array;
    });
    //    request.setRawHeader("Authorization", headerData.toLocal8Bit());
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
