#include "links.h"
#include <QUuid>

#include "db/db.h"
#include "linker.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Links::Links(QObject *parent) : QObject(parent)
{
    this->db = DB::getInstance();
    this->sortBy(OWL::KEY::UPDATED, "DESC");
}

void Links::sortBy(const OWL::KEY &key, const QString &order)
{
    this->links = this->db->getDBData(QString("select * from links ORDER BY %1 %2").arg(OWL::KEYMAP[key], order));
}

OWL::DB_LIST Links::items() const
{
    return this->links;
}

bool Links::insertLink(const QVariantMap &link)
{
    auto url = link[OWL::KEYMAP[OWL::KEY::LINK]].toString();
    auto color = link[OWL::KEYMAP[OWL::KEY::COLOR]].toString();
    auto pin = link[OWL::KEYMAP[OWL::KEY::PIN]].toInt();
    auto fav = link[OWL::KEYMAP[OWL::KEY::FAV]].toInt();
    auto tags = link[OWL::KEYMAP[OWL::KEY::TAG]].toStringList();
    auto preview = link[OWL::KEYMAP[OWL::KEY::PREVIEW]].toString();
    auto title = link[OWL::KEYMAP[OWL::KEY::TITLE]].toString();

    auto image_path = OWL::saveImage(Linker::getUrl(preview), OWL::LinksPath+QUuid::createUuid().toString());

    QVariantMap link_map =
    {
        {OWL::KEYMAP[OWL::KEY::LINK], url},
        {OWL::KEYMAP[OWL::KEY::TITLE], title},
        {OWL::KEYMAP[OWL::KEY::PIN], pin},
        {OWL::KEYMAP[OWL::KEY::FAV], fav},
        {OWL::KEYMAP[OWL::KEY::PREVIEW], image_path},
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::ADD_DATE], QDateTime::currentDateTime().toString()},
        {OWL::KEYMAP[OWL::KEY::UPDATED], QDateTime::currentDateTime().toString()}

    };

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::LINKS], link_map))
    {
        for(auto tg : tags)
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::LINKS], url, color);

        this->links << OWL::DB
                       ({
                            {OWL::KEY::LINK, url},
                            {OWL::KEY::TITLE, title},
                            {OWL::KEY::COLOR, color},
                            {OWL::KEY::PREVIEW, preview},
                            {OWL::KEY::PIN, QString::number(pin)},
                            {OWL::KEY::FAV, QString::number(fav)},
                            {OWL::KEY::UPDATED, QDateTime::currentDateTime().toString()},
                            {OWL::KEY::ADD_DATE, QDateTime::currentDateTime().toString()}

                        });
        return true;
    }

    return false;
}

bool Links::updateLink(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= links.size())
        return false;

    const auto oldValue = this->links[index][static_cast<OWL::KEY>(role)];

    if(oldValue == value.toString())
        return false;

    qDebug()<< "VALUE TO UPDATE"<<  OWL::KEYMAP[static_cast<OWL::KEY>(role)] << oldValue;

    this->links[index].insert(static_cast<OWL::KEY>(role), value.toString());

    this->updateLink(this->links[index]);

    return true;
}


bool Links::updateLink(const OWL::DB &link)
{
    auto url = link[OWL::KEY::LINK];
    auto color = link[OWL::KEY::COLOR];
    auto pin = link[OWL::KEY::PIN].toInt();
    auto fav = link[OWL::KEY::FAV].toInt();
    auto tags = link[OWL::KEY::TAG].split(",", QString::SkipEmptyParts);
    auto updated = link[OWL::KEY::UPDATED];

    QVariantMap link_map =
    {
        {OWL::KEYMAP[OWL::KEY::COLOR], color},
        {OWL::KEYMAP[OWL::KEY::PIN], pin},
        {OWL::KEYMAP[OWL::KEY::FAV], fav},
        {OWL::KEYMAP[OWL::KEY::UPDATED], updated}
    };

    for(auto tg : tags)
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::LINKS], url, color);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::LINKS], link_map, {{OWL::KEYMAP[OWL::KEY::LINK], url}} );
}

bool Links::removeLink(const QVariantMap &link)
{
    qDebug()<<link;
    return this->db->remove(OWL::TABLEMAP[OWL::TABLE::LINKS], link);
}

QVariantList Links::getLinkTags(const QString &link)
{
    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::LINKS], link);
}
