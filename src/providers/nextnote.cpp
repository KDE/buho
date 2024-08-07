#include "nextnote.h"
#include <QUrl>
//#include <QDomDocument>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QNetworkReply>
#include <QByteArrayView>

const QString NextNote::API = QStringLiteral("/index.php/apps/notes/api/v0.2/");

static const inline QNetworkRequest formRequest(const QUrl &url, const QString &user, const QString &password)
{
    if (!url.isValid() && !user.isEmpty() && !password.isEmpty())
        return QNetworkRequest();

    const QString concatenated = user + ":" + password;
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const auto headerData = QByteArrayLiteral("Basic ") + QByteArrayView(data);

    //    QVariantMap headers
    //    {
    //        {"Authorization", headerData.toLocal8Bit()},
    //        {QString::number(QNetworkRequest::ContentTypeHeader),"application/json"}
    //    };

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader(QByteArrayLiteral("Authorization"), headerData);

    return request;
}

NextNote::NextNote(QObject *parent)
    : AbstractNotesProvider(parent)
{
}

NextNote::~NextNote()
{
}

void NextNote::getNote(const QString &id)
{
    QUrl relativeUrl("../.." + NextNote::API + QString("notes/%1").arg(id));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

//    const auto request = formRequest(url, this->m_user, this->m_password);
    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    const auto headerData = QStringLiteral("Basic ") + QByteArrayView(data);

    QMap<QString, QString> header{{"Authorization", headerData}};

    auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array) {
        const auto notes = this->parseNotes(array);
        Q_EMIT this->noteReady(notes.isEmpty() ? FMH::MODEL() : notes.first());
        downloader->deleteLater();
    });

    downloader->getArray(url, header);
}

void NextNote::getBooklet(const QString &id)
{
    Q_UNUSED(id)
}

void NextNote::sendNotes(QByteArray array)
{
    Q_UNUSED(array)
    //    Q_EMIT this->notesReady(notes);
}

void NextNote::getNotes()
{
    QUrl relativeUrl("../.." + NextNote::API + QString("notes"));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = QStringLiteral("Basic ") + QByteArrayView(data);

    QMap<QString, QString> header{{"Authorization", headerData}};

    const auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array) {
        // exclude notes that have its own category
        FMH::MODEL_LIST notes;
        for (const auto &data : this->parseNotes(array)) {
            auto item = data;
            item[FMH::MODEL_KEY::STAMP] = item[FMH::MODEL_KEY::ID];
            item[FMH::MODEL_KEY::USER] = this->user();
            item[FMH::MODEL_KEY::SERVER] = this->provider();
            item[FMH::MODEL_KEY::FORMAT] = ".txt";

            if (item[FMH::MODEL_KEY::CATEGORY].isEmpty() || item[FMH::MODEL_KEY::CATEGORY].isNull())
                notes << item;
        }

        Q_EMIT this->notesReady(notes);
        downloader->deleteLater();
    });

    downloader->getArray(url, header);
}

void NextNote::getBooklets()
{
    QUrl relativeUrl("../.." + NextNote::API + QString("notes"));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = QStringLiteral("Basic ") + QByteArrayView(data);

    QMap<QString, QString> header{{"Authorization", headerData}};

    const auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array) {
        // exclude notes that do not have their own category
        FMH::MODEL_LIST booklets;
        for (const auto &data : this->parseNotes(array)) {
            auto item = data;
            item[FMH::MODEL_KEY::STAMP] = item[FMH::MODEL_KEY::ID];
            item[FMH::MODEL_KEY::USER] = this->user();
            item[FMH::MODEL_KEY::SERVER] = this->provider();
            item[FMH::MODEL_KEY::FORMAT] = ".txt";

            if (!item[FMH::MODEL_KEY::CATEGORY].isEmpty() && !item[FMH::MODEL_KEY::CATEGORY].isNull())
                booklets << item;
        }

        Q_EMIT this->bookletsReady(booklets);
        downloader->deleteLater();
    });

    downloader->getArray(url, header);
}

void NextNote::insertNote(const FMH::MODEL &note)
{
    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::FAVORITE}))).toJson();
    qDebug() << "UPLOADING NEW NOT" << QVariant(payload).toString();

    QUrl relativeUrl("../.." + NextNote::API + QString("notes"));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    const auto request = formRequest(url, this->m_user, this->m_password);

    auto restclient = new QNetworkAccessManager; // constructor
    QNetworkReply *reply = restclient->post(request, payload);
    connect(reply, &QNetworkReply::finished, [=, __note = note]() {
        qDebug() << "Note insertyion finished?";
        const auto notes = this->parseNotes(reply->readAll());
        Q_EMIT this->noteInserted([&]() -> FMH::MODEL {
            FMH::MODEL note;
            if (!notes.isEmpty()) {
                note = notes.first();
                note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID]; // adds the id of the uploaded note as a stamp
                note[FMH::MODEL_KEY::ID] = __note[FMH::MODEL_KEY::ID]; // adds the url of the original local note
                note[FMH::MODEL_KEY::SERVER] = this->m_provider; // adds the provider server address
                note[FMH::MODEL_KEY::USER] = this->m_user; // adds the user name
            }
            return note;
        }());

        reply->deleteLater();
        restclient->deleteLater();
    });
}

void NextNote::insertBooklet(const FMH::MODEL &booklet)
{
    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::FAVORITE, FMH::MODEL_KEY::CATEGORY}))).toJson();
    qDebug() << "UPLOADING NEW BOOKLET" << QVariant(payload).toString();

    QUrl relativeUrl("../.." + NextNote::API + QString("notes"));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    const auto request = formRequest(url, this->m_user, this->m_password);

    auto restclient = new QNetworkAccessManager; // constructor
    QNetworkReply *reply = restclient->post(request, payload);
    connect(reply, &QNetworkReply::finished, [=, __booklet = booklet]() {
        qDebug() << "Note insertyion finished?";
        const auto booklets = this->parseNotes(reply->readAll());
        Q_EMIT this->bookletInserted([&]() -> FMH::MODEL {
            FMH::MODEL p_booklet;
            if (!booklets.isEmpty()) {
                p_booklet = booklets.first();
                p_booklet[FMH::MODEL_KEY::STAMP] = p_booklet[FMH::MODEL_KEY::ID]; // adds the id of the local note as a stamp
                p_booklet[FMH::MODEL_KEY::ID] = __booklet[FMH::MODEL_KEY::ID]; // adds the id of the local note as a stamp
                p_booklet[FMH::MODEL_KEY::SERVER] = this->m_provider; // adds the provider server address
                p_booklet[FMH::MODEL_KEY::USER] = this->m_user; // adds the user name
            }
            return p_booklet;
        }());

        restclient->deleteLater();
        reply->deleteLater();
    });
}

void NextNote::updateNote(const QString &id, const FMH::MODEL &note)
{
    if (id.isEmpty() || note.isEmpty()) {
        qWarning() << "The id or note are empty. Can not proceed. NextNote::update";
        return;
    }

    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::FAVORITE, FMH::MODEL_KEY::MODIFIED, FMH::MODEL_KEY::CATEGORY}))).toJson();
    qDebug() << "UPDATING NOTE" << QVariant(payload).toString();

    QUrl relativeUrl("../.." + NextNote::API + QString("notes/%1").arg(id));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    qDebug() << "tryiong to update note" << url;
    const auto request = formRequest(url, this->m_user, this->m_password);

    auto restclient = new QNetworkAccessManager; // constructor
    QNetworkReply *reply = restclient->put(request, payload);
    connect(reply, &QNetworkReply::finished, [=, __note = note]() {
        qDebug() << "Note update finished?" << reply->errorString();
        const auto notes = this->parseNotes(reply->readAll());
        Q_EMIT this->noteUpdated([&]() -> FMH::MODEL {
            FMH::MODEL note;
            if (notes.isEmpty())
                return note;

            note = notes.first();
            note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID]; // adds the id of the local note as a stamp
            note[FMH::MODEL_KEY::ID] = __note[FMH::MODEL_KEY::ID]; // adds the id of the local note as a stamp
            note[FMH::MODEL_KEY::SERVER] = this->m_provider; // adds the provider server address
            note[FMH::MODEL_KEY::USER] = this->m_user; // adds the user name

            return note;
        }());

        restclient->deleteLater();
        reply->deleteLater();
    });
}

void NextNote::updateBooklet(const QString &id, const FMH::MODEL &booklet)
{
    if (id.isEmpty() || booklet.isEmpty()) {
        qWarning() << "The id or note are empty. Can not proceed. NextNote::update";
        return;
    }

    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::CATEGORY}))).toJson();
    qDebug() << "UPDATING BOOKLET" << QVariant(payload).toString();

    QUrl relativeUrl("../.." + NextNote::API + QString("notes/%1").arg(id));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    qDebug() << "tryiong to update note" << url;
    const auto request = formRequest(url, this->m_user, this->m_password);

    auto restclient = new QNetworkAccessManager; // constructor
    QNetworkReply *reply = restclient->put(request, payload);
    connect(reply, &QNetworkReply::finished, [=, __booklet = booklet]() {
        qDebug() << "Note update finished?" << reply->errorString();
        const auto booklets = this->parseNotes(reply->readAll());
        Q_EMIT this->bookletUpdated([&]() -> FMH::MODEL {
            FMH::MODEL booklet;

            if (booklets.isEmpty())
                return booklet;

            booklet = booklets.first();
            booklet[FMH::MODEL_KEY::STAMP] = booklet[FMH::MODEL_KEY::ID]; // adds the stamp to the local note form the remote id
            booklet[FMH::MODEL_KEY::ID] = __booklet[FMH::MODEL_KEY::ID]; // adds back the id of the local booklet
            booklet[FMH::MODEL_KEY::SERVER] = this->m_provider; // adds the provider server address
            booklet[FMH::MODEL_KEY::USER] = this->m_user; // adds the user name

            return booklet;
        }());

        restclient->deleteLater();
        reply->deleteLater();
    });
}

void NextNote::removeNote(const QString &id)
{
    if (id.isEmpty()) {
        qWarning() << "The id is empty. Can not proceed. NextNote::remove";
        return;
    }

    QUrl relativeUrl("../.." + NextNote::API + QString("notes/%1").arg(id));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);
    qDebug() << "THE RESOLVED URL IS" << url << this->m_provider;

    const auto request = formRequest(url, this->m_user, this->m_password);
    qDebug() << "trying to remove nextnote <<" << url;
    auto restclient = new QNetworkAccessManager; // constructor
    QNetworkReply *reply = restclient->deleteResource(request);
    connect(reply, &QNetworkReply::finished, [=]() {
        qDebug() << "Note remove finished?" << reply->errorString();
        Q_EMIT this->noteRemoved();
        restclient->deleteLater();
        reply->deleteLater();
    });
}

void NextNote::removeBooklet(const QString &id)
{
    this->removeNote(id);
}

const FMH::MODEL_LIST NextNote::parseNotes(const QByteArray &array)
{
    FMH::MODEL_LIST res;
    //	qDebug()<< "trying to parse notes" << array;
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        qDebug() << "ERROR PARSING" << array;
        return res;
    }

    const auto data = jsonResponse.toVariant();

    if (data.isNull() || !data.isValid())
        return res;

    if (!data.toList().isEmpty())
        res << FMH::toModelList(data.toList());
    else
        res << FMH::toModel(data.toMap());

    return res;
}
