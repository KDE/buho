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
#include "db.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

DBActions::DBActions(QObject *parent) : QObject(parent)
{
    qDebug() << "Getting collectionDB info from: " << OWL::CollectionDBPath;

    qDebug()<< "Starting DBActions";
    this->db = DB::getInstance();
    this->tag =  Tagging::getInstance(OWL::App, OWL::version, "org.kde.buho", OWL::comment);

}

DBActions::~DBActions() {}

QVariantList DBActions::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->db->getQuery(queryTxt);

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

bool DBActions::execQuery(const QString &queryTxt)
{
    auto query = this->db->getQuery(queryTxt);
    return query.exec();
}

void DBActions::removeAbtractTags(const QString &key, const QString &lot)
{

}

