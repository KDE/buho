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

#include "../buho_version.h"

namespace OWL
{
    Q_NAMESPACE  
    enum class TABLE : uint8_t
    {
        NOTES,
        NOTES_SYNC,
        BOOKS,
        BOOKLETS,
        BOOKLETS_SYNC,
        LINKS,
        NONE
    };

    static const QMap<TABLE,QString> TABLEMAP =
    {
        {TABLE::NOTES,"notes"},
        {TABLE::NOTES_SYNC,"notes_sync"},
        {TABLE::BOOKS,"books"},
        {TABLE::BOOKLETS,"booklets"},
        {TABLE::BOOKLETS_SYNC,"booklets_sync"},
        {TABLE::LINKS,"links"},
    };

//    enum KEY : uint8_t
//    {
//        URL,
//        UPDATED,
//        ID,
//        TITLE,
//        BODY,
//        FAV,
//        COLOR,
//        ADD_DATE,
//        TAG,
//        PREVIEW,
//        IMAGE,
//        LINK,
//        PIN,
//        NONE
//    }; Q_ENUM_NS(KEY);

//    typedef QHash<OWL::KEY, QString> DB;
//    typedef QList<DB> DB_LIST;

//    static const DB KEYMAP =
//    {
//        {KEY::ID, "id"},
//        {KEY::BODY, "body"},
//        {KEY::UPDATED, "updated"},
//        {KEY::TITLE, "title"},
//        {KEY::URL, "url"},
//        {KEY::FAV, "fav"},
//        {KEY::PIN, "pin"},
//        {KEY::COLOR, "color"},
//        {KEY::ADD_DATE, "addDate"},
//        {KEY::TAG, "tag"},
//        {KEY::PREVIEW, "preview"},
//        {KEY::IMAGE, "image"},
//        {KEY::LINK, "link"}
//    };

//    static const QHash<QString, OWL::KEY> MAPKEY =
//    {
//        {KEYMAP[KEY::ID], KEY::ID},
//        {KEYMAP[KEY::BODY], KEY::BODY},
//        {KEYMAP[KEY::UPDATED], KEY::UPDATED},
//        {KEYMAP[KEY::TITLE], KEY::TITLE},
//        {KEYMAP[KEY::URL], KEY::URL},
//        {KEYMAP[KEY::FAV], KEY::FAV},
//        {KEYMAP[KEY::PIN], KEY::PIN},
//        {KEYMAP[KEY::COLOR], KEY::COLOR},
//        {KEYMAP[KEY::ADD_DATE], KEY::ADD_DATE},
//        {KEYMAP[KEY::TAG], KEY::TAG},
//        {KEYMAP[KEY::PREVIEW], KEY::PREVIEW},
//        {KEYMAP[KEY::IMAGE], KEY::IMAGE},
//        {KEYMAP[KEY::LINK], KEY::LINK}
//    };

    const QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/";
    const QString NotesPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/notes/";
    const QString BooksPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/books/";
    const QString LinksPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/links/";
    const QString App = "Buho";
    const QString version = BUHO_VERSION_STRING;
    const QString comment = "Notes taking and link collector manager";
    const QString DBName = "collection.db";

    inline void saveJson(QJsonDocument document, QString fileName)
    {
        QFile jsonFile(fileName);
        jsonFile.open(QFile::WriteOnly);
        jsonFile.write(document.toJson());
        jsonFile.close();
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
