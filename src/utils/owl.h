#ifndef OWL_H
#define OWL_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>
#include <QJsonDocument>
#include <QJsonObject>



namespace OWL
{
    Q_NAMESPACE


    enum class W : uint8_t
    {
        TITLE,
        BODY,
        IMAGE,
        VIDEO,
        LINK,
        TAG,
        AUTHOR,
        DATE,
        NOTE,
        TAGS,
        ADD_DATE,
        COLOR
    };

    static const QMap<W, QString> SLANG =
    {
        {W::TITLE, "title"},
        {W::BODY, "body"},
        {W::IMAGE, "image"},
        {W::VIDEO, "video"},
        {W::LINK, "link"},
        {W::TAG, "tag"},
        {W::AUTHOR, "author"},
        {W::DATE, "date"},
        {W::NOTE, "note"},
        {W::TAGS, "tags"},
        {W::ADD_DATE, "addDate"},
        {W::COLOR, "color"}
    };

    enum class TABLE : uint8_t
    {
        NOTES,
        NOTES_TAGS,
        TAGS,
        BOOKS,
        PAGES,
        BOOKS_PAGES,
        LINKS,
        LINKS_TAGS,
        PAGES_TAGS,
        NONE
    };

    static const QMap<TABLE,QString> TABLEMAP =
    {
        {TABLE::NOTES,"notes"},
        {TABLE::NOTES_TAGS,"notes_tags"},
        {TABLE::TAGS,"tags"},
        {TABLE::BOOKS,"books"},
        {TABLE::PAGES,"pages"},
        {TABLE::BOOKS_PAGES,"books_pages"},
        {TABLE::LINKS,"links"},
        {TABLE::LINKS_TAGS,"links_tags"},
        {TABLE::PAGES_TAGS,"pages_tags"},
        {TABLE::LINKS_TAGS,"links_tags"}
    };

    enum class KEY :uint8_t
    {
        URL,
        UPDATED,
        ID,
        TITLE,
        BODY,
        FAV,
        COLOR,
        ADD_DATE,
        TAG,
        PREVIEW,
        IMAGE,
        LINK,
        PIN,
        NONE
    };

    typedef QMap<OWL::KEY, QString> DB;
    typedef QList<DB> DB_LIST;

    static const DB KEYMAP =
    {
        {KEY::ID, "id"},
        {KEY::BODY, "body"},
        {KEY::UPDATED, "updated"},
        {KEY::TITLE, "title"},
        {KEY::URL, "url"},
        {KEY::FAV, "fav"},
        {KEY::PIN, "pin"},
        {KEY::COLOR, "color"},
        {KEY::ADD_DATE, "addDate"},
        {KEY::TAG, "tag"},
        {KEY::PREVIEW, "preview"},
        {KEY::IMAGE, "image"},
        {KEY::LINK, "link"}

    };

    const QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/";
    const QString NotesPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/notes/";
    const QString BooksPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/books/";
    const QString LinksPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/links/";
    const QString App = "Buho";
    const QString version = "1.0";
    const QString comment = "Notes taking and link collector manager";
    const QString DBName = "collection.db";

    inline bool fileExists(const QString &url)
    {
        QFileInfo path(url);
        if (path.exists()) return true;
        else return false;
    }

    inline void saveJson(QJsonDocument document, QString fileName)
    {
        QFile jsonFile(fileName);
        jsonFile.open(QFile::WriteOnly);
        jsonFile.write(document.toJson());
    }

    inline QVariantMap openJson(const QString &url)
    {
        QString val;
        QFile file;
        file.setFileName(url);
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        val = file.readAll();
        file.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        QJsonObject obj = d.object();
        return obj.toVariantMap();
    }



    inline QString saveImage(QByteArray array, const QString &path)
    {

        if(!array.isNull()&&!array.isEmpty())
        {
            QImage img;
            img.loadFromData(array);
            QString name = path;
            name.replace("/", "-");
            name.replace("&", "-");
            QString format = "JPEG";
            if (img.save(path+".jpg", format.toLatin1(), 100))
                return path+".jpg";
            else  qDebug() << "couldn't save artwork";
        }else qDebug()<<"array is empty";

        return QString();
    }
}


#endif // OWL_H
