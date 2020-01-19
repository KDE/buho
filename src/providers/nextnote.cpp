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

const QString NextNote::API = QStringLiteral("https://PROVIDER/index.php/apps/notes/api/v0.2/");

static const inline QNetworkRequest formRequest(const QUrl &url, const  QString &user, const QString &password)
{
	if(!url.isValid() && !user.isEmpty() && !password.isEmpty())
		return QNetworkRequest();

	const QString concatenated = user + ":" + password;
	const QByteArray data = concatenated.toLocal8Bit().toBase64();
	const QString headerData = "Basic " + data;

	//    QVariantMap headers
	//    {
	//        {"Authorization", headerData.toLocal8Bit()},
	//        {QString::number(QNetworkRequest::ContentTypeHeader),"application/json"}
	//    };

	QNetworkRequest request;
	request.setUrl(QUrl(url));
	request.setHeader(QNetworkRequest::ContentTypeHeader,"application/json");
	request.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());

	return request;
}

NextNote::NextNote(QObject *parent) : AbstractNotesProvider(parent)
{

}

NextNote::~NextNote()
{
}

void NextNote::getNote(const QString &id)
{
	auto url = QString(NextNote::API+"%1%2").replace("PROVIDER", this->m_provider).arg("notes/", id);

	QString concatenated = this->m_user + ":" + this->m_password;
	QByteArray data = concatenated.toLocal8Bit().toBase64();
	QString headerData = "Basic " + data;

	QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

	auto downloader = new FMH::Downloader;
	connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array)
	{
		const auto notes = this->parseNotes(array);
		emit this->noteReady(notes.isEmpty() ? FMH::MODEL() : notes.first());
		downloader->deleteLater();
	});

	downloader->getArray(url, header);
}

void NextNote::getBooklet(const QString &id)
{

}

void NextNote::sendNotes(QByteArray array)
{
	//    emit this->notesReady(notes);
}

void NextNote::getNotes()
{
	auto url = NextNote::formatUrl(this->m_user, this->m_password, this->m_provider)+"notes";

	QString concatenated = this->m_user + ":" + this->m_password;
	QByteArray data = concatenated.toLocal8Bit().toBase64();
	QString headerData = "Basic " + data;

	QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

	const auto downloader = new FMH::Downloader;
	connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array)
	{
		//exclude notes that have its own category
		FMH::MODEL_LIST notes;
		for(const auto &data : this->parseNotes(array))
		{
			auto item = data;
            item[FMH::MODEL_KEY::STAMP] = item[FMH::MODEL_KEY::ID];
			item[FMH::MODEL_KEY::USER] = this->user ();
			item[FMH::MODEL_KEY::SERVER] = this->provider ();
			item[FMH::MODEL_KEY::FORMAT] = ".txt";

			if(item[FMH::MODEL_KEY::CATEGORY].isEmpty() || item[FMH::MODEL_KEY::CATEGORY].isNull())
				notes << item;
		}

		emit this->notesReady(notes);
		downloader->deleteLater();
	});

	downloader->getArray(url, header);
}

void NextNote::getBooklets()
{
	auto url = NextNote::formatUrl(this->m_user, this->m_password, this->m_provider)+"notes";

	QString concatenated = this->m_user + ":" + this->m_password;
	QByteArray data = concatenated.toLocal8Bit().toBase64();
	QString headerData = "Basic " + data;

	QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

	const auto downloader = new FMH::Downloader;
	connect(downloader, &FMH::Downloader::dataReady, [=](QByteArray array)
	{
		//exclude notes that do not have their own category
		FMH::MODEL_LIST booklets;
		for(const auto &data : this->parseNotes(array))
		{
			auto item = data;
            item[FMH::MODEL_KEY::STAMP] =  item[FMH::MODEL_KEY::ID];
            item[FMH::MODEL_KEY::USER] = this->user ();
            item[FMH::MODEL_KEY::SERVER] = this->provider ();
            item[FMH::MODEL_KEY::FORMAT] = ".txt";

			if(!item[FMH::MODEL_KEY::CATEGORY].isEmpty() && !item[FMH::MODEL_KEY::CATEGORY].isNull())
				booklets << item;
		}

		emit this->bookletsReady(booklets);
		downloader->deleteLater();
	});

	downloader->getArray(url, header);
}

void NextNote::insertNote(const FMH::MODEL &note)
{
    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::FAVORITE}))).toJson();
	qDebug() << "UPLOADING NEW NOT" << QVariant(payload).toString();

	const auto url = QString(NextNote::API+"%1").replace("PROVIDER", this->m_provider).arg("notes");

	const auto request = formRequest(url, this->m_user, this->m_password);

	auto restclient = new QNetworkAccessManager; //constructor
	QNetworkReply *reply = restclient->post(request,payload);
    connect(reply, &QNetworkReply::finished, [=, __note = note]()
	{
		qDebug() << "Note insertyion finished?";
		const auto notes = this->parseNotes(reply->readAll());
		emit this->noteInserted([&]() -> FMH::MODEL {
									FMH::MODEL note;
									if(!notes.isEmpty())
									{
										note = notes.first();
										note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID]; //adds the id of the uploaded note as a stamp
                                        note[FMH::MODEL_KEY::ID] = __note[FMH::MODEL_KEY::ID]; //adds the url of the original local note
										note[FMH::MODEL_KEY::SERVER] = this->m_provider; //adds the provider server address
										note[FMH::MODEL_KEY::USER] = this->m_user; //adds the user name
									}
									return note;
								}());

		reply->deleteLater ();
		restclient->deleteLater();
	});
}

void NextNote::insertBooklet(const FMH::MODEL &booklet)
{
    QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::CONTENT, FMH::MODEL_KEY::FAVORITE, FMH::MODEL_KEY::CATEGORY}))).toJson();
	qDebug() << "UPLOADING NEW BOOKLET" << QVariant(payload).toString();

	const auto url = QString(NextNote::API+"%1").replace("PROVIDER", this->m_provider).arg("notes");

	const auto request = formRequest(url, this->m_user, this->m_password);

	auto restclient = new QNetworkAccessManager; //constructor
	QNetworkReply *reply = restclient->post(request,payload);
	connect(reply, &QNetworkReply::finished, [=, __booklet = booklet]()
	{
		qDebug() << "Note insertyion finished?";
        const auto booklets = this->parseNotes(reply->readAll());
		emit this->bookletInserted([&]() -> FMH::MODEL {
                                    FMH::MODEL p_booklet;
                                    if(!booklets.isEmpty())
									{
                                        p_booklet = booklets.first();
                                        p_booklet[FMH::MODEL_KEY::STAMP] = p_booklet[FMH::MODEL_KEY::ID]; //adds the id of the local note as a stamp
                                        p_booklet[FMH::MODEL_KEY::ID] = __booklet[FMH::MODEL_KEY::ID]; //adds the id of the local note as a stamp
                                        p_booklet[FMH::MODEL_KEY::SERVER] = this->m_provider; //adds the provider server address
                                        p_booklet[FMH::MODEL_KEY::USER] = this->m_user; //adds the user name
									}
                                    return p_booklet;
								}());

		restclient->deleteLater();
        reply->deleteLater();
	});
}

void NextNote::updateNote(const QString &id, const FMH::MODEL &note)
{
	if(id.isEmpty() || note.isEmpty())
	{
		qWarning()<< "The id or note are empty. Can not proceed. NextNote::update";
		return;
	}

	QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::CONTENT,
																					  FMH::MODEL_KEY::FAVORITE,
																					  FMH::MODEL_KEY::MODIFIED,
																					  FMH::MODEL_KEY::CATEGORY}))).toJson();
	qDebug() << "UPDATING NOTE" << QVariant(payload).toString();

	const auto url = QString(NextNote::API+"%1%2").replace("PROVIDER", this->m_provider).arg("notes/", id);

	qDebug()<< "tryiong to update note" << url;
	const auto request = formRequest(url, this->m_user, this->m_password);

	auto restclient = new QNetworkAccessManager; //constructor
	QNetworkReply *reply = restclient->put(request, payload);
	connect(reply, &QNetworkReply::finished, [=, __note = note]()
	{
		qDebug() << "Note update finished?" << reply->errorString();
		const auto notes = this->parseNotes(reply->readAll());
		emit this->noteUpdated([&]() -> FMH::MODEL {
								   FMH::MODEL note;
								   if(notes.isEmpty())
								   return note;

								   note = notes.first();
								   note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID]; //adds the id of the local note as a stamp
								   note[FMH::MODEL_KEY::ID] = __note[FMH::MODEL_KEY::ID]; //adds the id of the local note as a stamp
								   note[FMH::MODEL_KEY::SERVER] = this->m_provider; //adds the provider server address
								   note[FMH::MODEL_KEY::USER] = this->m_user; //adds the user name

								   return note;
							   }());

		restclient->deleteLater();
        reply->deleteLater();
	});
}

void NextNote::updateBooklet(const QString &id, const FMH::MODEL &booklet)
{
	if(id.isEmpty() || booklet.isEmpty())
	{
		qWarning()<< "The id or note are empty. Can not proceed. NextNote::update";
		return;
	}

	QByteArray payload = QJsonDocument::fromVariant(FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::CONTENT,
																					  FMH::MODEL_KEY::CATEGORY}))).toJson();
	qDebug() << "UPDATING BOOKLET" << QVariant(payload).toString();

	const auto url = QString(NextNote::API+"%1%2").replace("PROVIDER", this->m_provider).arg("notes/", id);

	qDebug()<< "tryiong to update note" << url;
	const auto request = formRequest(url, this->m_user, this->m_password);

	auto restclient = new QNetworkAccessManager; //constructor
	QNetworkReply *reply = restclient->put(request, payload);
	connect(reply, &QNetworkReply::finished, [=, __booklet = booklet]()
	{
		qDebug() << "Note update finished?" << reply->errorString();
		const auto booklets = this->parseNotes(reply->readAll());
		emit this->bookletUpdated([&]() -> FMH::MODEL {
								   FMH::MODEL booklet;

									  if(booklets.isEmpty())
								   return booklet;

								   booklet = booklets.first();
								   booklet[FMH::MODEL_KEY::STAMP] = booklet[FMH::MODEL_KEY::ID]; //adds the stamp to the local note form the remote id
                                   booklet[FMH::MODEL_KEY::ID] = __booklet[FMH::MODEL_KEY::ID]; //adds back the id of the local booklet
								   booklet[FMH::MODEL_KEY::SERVER] = this->m_provider; //adds the provider server address
								   booklet[FMH::MODEL_KEY::USER] = this->m_user; //adds the user name

								   return booklet;
							   }());

		restclient->deleteLater();
        reply->deleteLater();
	});
}

void NextNote::removeNote(const QString &id)
{
	if(id.isEmpty())
	{
		qWarning()<< "The id is empty. Can not proceed. NextNote::remove";
		return;
	}

	const auto url = QString(NextNote::API+"%1%2").replace("PROVIDER", this->m_provider).arg("notes/", id);
	const auto request = formRequest(url, this->m_user, this->m_password);
	qDebug()<< "trying to remove nextnote <<" << url;
	auto restclient = new QNetworkAccessManager; //constructor
	QNetworkReply *reply = restclient->deleteResource(request);
	connect(reply, &QNetworkReply::finished, [=]()
	{
		qDebug() << "Note remove finished?" << reply->errorString();
		emit this->noteRemoved();
		restclient->deleteLater();
        reply->deleteLater();
	});
}

void NextNote::removeBooklet(const QString &id)
{
    this->removeNote(id);
}

const QString NextNote::formatUrl(const QString &user, const QString &password, const QString &provider)
{
	auto url = NextNote::API;
	url.replace("USER", user);
	url.replace("PASSWORD", password);
	url.replace("PROVIDER", provider);
	return url;
}

const FMH::MODEL_LIST NextNote::parseNotes(const QByteArray &array)
{
	FMH::MODEL_LIST res;
//	qDebug()<< "trying to parse notes" << array;
	QJsonParseError jsonParseError;
	QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

	if (jsonParseError.error != QJsonParseError::NoError)
	{
        qDebug()<< "ERROR PARSING" << array;
		return res;
	}

	const auto data = jsonResponse.toVariant();

	if(data.isNull() || !data.isValid())
		return res;

	if(!data.toList().isEmpty())
		res << FMH::toModelList(data.toList());
	else
		res << FMH::toModel(data.toMap());

	return res;
}


