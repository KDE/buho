/***
Buho  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#include "dbactions.h"
#include <QJsonDocument>
#include <QVariantMap>
#include <QUuid>
#include <QDateTime>
#include "linker.h"

DBActions::DBActions(QObject *parent) : DB(parent)
{
    qDebug() << "Getting collectionDB info from: " << OWL::CollectionDBPath;

    qDebug()<< "Starting DBActions";
}

DBActions::~DBActions() {}

OWL::DB_LIST DBActions::getDBData(const QString &queryTxt)
{
    OWL::DB_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            OWL::DB data;
            for(auto key : OWL::KEYMAP.keys())
                if(query.record().indexOf(OWL::KEYMAP[key])>-1)
                    data.insert(key, query.value(OWL::KEYMAP[key]).toString());

            mapList<< data;
        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

QVariantList DBActions::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            QVariantMap data;
            for(auto key : OWL::KEYMAP.keys())
                if(query.record().indexOf(OWL::KEYMAP[key])>-1)
                    data[OWL::KEYMAP[key]] = query.value(OWL::KEYMAP[key]).toString();
            mapList<< data;

        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

bool DBActions::insertNote(const QString &title, const QString &body, const QString &color, const QString &tags)
{
    auto id = QUuid::createUuid().toString();

    QVariantMap note_map =
    {
        {OWL::KEYMAP[OWL::KEY::ID], id},
        {OWL::KEYMAP[OWL::KEY::TITLE], title},
        {OWL::KEYMAP[OWL::KEY::BODY], body},
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::UPDATED], QDateTime::currentDateTime()},
        {OWL::KEYMAP[OWL::KEY::ADD_DATE], QDateTime::currentDateTime()}
    };

    //    if(!tags.isEmpty())
    //    {
    //        for(auto tag : tags.split(","))
    //        {
    //            this->insert(OWL::TABLEMAP[OWL::TABLE::TAGS], {{OWL::KEYMAP[OWL::KEY::TAG], tag}});
    //            this->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_TAGS],
    //            {
    //                {OWL::KEYMAP[OWL::KEY::TAG], tag},
    //                {OWL::KEYMAP[OWL::KEY::URL], note_url}
    //            });
    //        }
    //    }

    if(this->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], note_map))
    {
        this->noteInserted(note_map);
        return true;
    }

    return false;
}

bool DBActions::updateNote(const QString &id, const QString &title, const QString &body, const QString &color, const QString &tags)
{
    OWL::DB note =
    {
        {OWL::KEY::TITLE, title},
        {OWL::KEY::BODY, body},
        {OWL::KEY::COLOR, color},
        {OWL::KEY::UPDATED, QDateTime::currentDateTime().toString()}
    };

    return this->update(OWL::TABLEMAP[OWL::TABLE::NOTES], note, {{OWL::KEYMAP[OWL::KEY::ID], id}} );
}

QVariantList DBActions::getNotes()
{
    return this->get("select * from notes");
}

bool DBActions::insertLink(const QString &link, const QString &title, const QString &preview, const QString &color, const QString &tags)
{
    auto image_path = OWL::saveImage(Linker::getUrl(preview), OWL::LinksPath+QUuid::createUuid().toString());

    QVariantMap link_map =
    {
        {OWL::KEYMAP[OWL::KEY::LINK], link},
        {OWL::KEYMAP[OWL::KEY::TITLE], title},
        {OWL::KEYMAP[OWL::KEY::PREVIEW], image_path},
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::ADD_DATE], QDateTime::currentDateTime()}
    };

    qDebug()<< link_map;
    if(this->insert(OWL::TABLEMAP[OWL::TABLE::LINKS], link_map))
    {
        this->linkInserted(link_map);
        return true;
    }

    return false;
}

QVariantList DBActions::getLinks()
{
    return this->get("select * from links");
}

bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->getQuery(queryTxt);
    return query.exec();
}

