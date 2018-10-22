#include "links.h"
#include <QUuid>

#include "db/db.h"
#include "linker.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Links::Links(QObject *parent) : BaseList(parent)
{
    this->db = DB::getInstance();
    this->tag =  Tagging::getInstance(OWL::App, OWL::version, "org.kde.buho", OWL::comment);
    this->sortList();

    connect(this, &Links::sortByChanged, this, &Links::sortList);
    connect(this, &Links::orderChanged, this, &Links::sortList);
}

void Links::sortList()
{
    emit this->preListChanged();
    this->links = this->db->getDBData(QString("select * from links ORDER BY %1 %2").arg(
                                          OWL::KEYMAP[this->sort],
                                      this->order == ORDER::ASC ? "asc" : "desc"));
    emit this->postListChanged();
}

QVariantMap Links::get(const int &index) const
{
    if(index >= this->links.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto note = this->links.at(index);

    for(auto key : note.keys())
        res.insert(OWL::KEYMAP[key], note[key]);

    return res;
}

OWL::DB_LIST Links::items() const
{
    return this->links;
}

bool Links::insert(const QVariantMap &link)
{
    emit this->preItemAppended();

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
                            {OWL::KEY::PREVIEW, image_path},
                            {OWL::KEY::PIN, QString::number(pin)},
                            {OWL::KEY::FAV, QString::number(fav)},
                            {OWL::KEY::UPDATED, QDateTime::currentDateTime().toString()},
                            {OWL::KEY::ADD_DATE, QDateTime::currentDateTime().toString()}

                        });

        emit postItemAppended();

        return true;
    } else qDebug()<< "LINK COULD NOT BE INSTED";

    return false;
}

bool Links::update(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= links.size())
        return false;

    const auto oldValue = this->links[index][static_cast<OWL::KEY>(role)];

    if(oldValue == value.toString())
        return false;

    qDebug()<< "VALUE TO UPDATE"<<  OWL::KEYMAP[static_cast<OWL::KEY>(role)] << oldValue;

    this->links[index].insert(static_cast<OWL::KEY>(role), value.toString());

    this->update(this->links[index]);

    return true;
}

bool Links::update(const QVariantMap &data, const int &index)
{
    if(index < 0 || index >= this->links.size())
        return false;

    auto newData = this->links[index];
    QVector<int> roles;

    for(auto key : data.keys())
        if(newData[OWL::MAPKEY[key]] != data[key].toString())
        {
            newData.insert(OWL::MAPKEY[key], data[key].toString());
            roles << OWL::MAPKEY[key];
        }

    this->links[index] = newData;

    if(this->update(newData))
    {
        emit this->updateModel(index, roles);
        return true;
    }

    return false;
}

bool Links::update(const OWL::DB &link)
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

bool Links::remove(const int &index)
{
    emit this->preItemRemoved(index);

    auto linkUrl = this->links.at(index)[OWL::KEY::LINK];
    QVariantMap link = {{OWL::KEYMAP[OWL::KEY::LINK], linkUrl}};

    if(this->db->remove(OWL::TABLEMAP[OWL::TABLE::LINKS], link))
    {
        this->links.removeAt(index);
        emit this->postItemRemoved();
        return true;
    }

    return false;
}

QVariantList Links::getTags(const int &index)
{
    if(index < 0 || index >= this->links.size())
        return QVariantList();

    auto link = this->links.at(index)[OWL::KEY::LINK];

    return this->tag->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::LINKS], link);
}
