#include "links.h"
#include <QUuid>

#include "db/db.h"
#include "linker.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

Links::Links(QObject *parent) : MauiList(parent)
{
    this->db = DB::getInstance();
    this->sortList();

    connect(this, &Links::sortByChanged, this, &Links::sortList);
    connect(this, &Links::orderChanged, this, &Links::sortList);
}

void Links::sortList()
{
    emit this->preListChanged();
    this->links = this->db->getDBData(QString("select * from links ORDER BY %1 %2").arg(
                                          FMH::MODEL_NAME[static_cast<FMH::MODEL_KEY>(this->sort)],
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
        res.insert(FMH::MODEL_NAME[key], note[key]);

    return res;
}

FMH::MODEL_LIST Links::items() const
{
    return this->links;
}

void Links::setSortBy(const Links::SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

Links::SORTBY Links::getSortBy() const
{
    return this->sort;
}

void Links::setOrder(const Links::ORDER &order)
{
    if(this->order == order)
        return;

    this->order = order;
    emit this->orderChanged();
}

Links::ORDER Links::getOrder() const
{
    return this->order;
}

bool Links::insert(const QVariantMap &link)
{
    emit this->preItemAppended();

    auto __model = FMH::toModel(link);
    __model[FMH::MODEL_KEY::ADDDATE] =  QDateTime::currentDateTime().toString();
    __model[FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString();
    __model[FMH::MODEL_KEY::PREVIEW] =  OWL::saveImage(Linker::getUrl(__model[FMH::MODEL_KEY::PREVIEW]), OWL::LinksPath.toString()+QUuid::createUuid().toString());


    __model = FMH::filterModel(__model, {FMH::MODEL_KEY::URL,
                                         FMH::MODEL_KEY::TITLE,
                                         FMH::MODEL_KEY::PREVIEW,
                                         FMH::MODEL_KEY::COLOR,
                                         FMH::MODEL_KEY::FAVORITE,
                                         FMH::MODEL_KEY::PIN,
                                         FMH::MODEL_KEY::MODIFIED,
                                         FMH::MODEL_KEY::ADDDATE});

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::LINKS], FMH::toMap(__model)))
    {
        for(const auto &tg : __model[FMH::MODEL_KEY::TAG].split(","))
            Tagging::getInstance()->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::LINKS], __model[FMH::MODEL_KEY::URL]);
        this->links << __model;

        emit postItemAppended();
        return true;
    } else qDebug()<< "LINK COULD NOT BE INSTED";

    return false;
}

bool Links::update(const int &index, const QVariant &value, const int &role)
{
    if(index < 0 || index >= links.size())
        return false;

    const auto oldValue = this->links[index][static_cast<FMH::MODEL_KEY>(role)];

    if(oldValue == value.toString())
        return false;

    qDebug()<< "VALUE TO UPDATE"<<  FMH::MODEL_NAME[static_cast<FMH::MODEL_KEY>(role)] << oldValue;

    this->links[index].insert(static_cast<FMH::MODEL_KEY>(role), value.toString());

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
        if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
        {
            newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
            roles << FMH::MODEL_NAME_KEY[key];
        }

    this->links[index] = newData;

    if(this->update(newData))
    {
        qDebug() << "update link" << newData;

        emit this->updateModel(index, roles);
        return true;
    }

    return false;
}

bool Links::update(const FMH::MODEL &link)
{
    auto url = link[FMH::MODEL_KEY::LINK];
    auto color = link[FMH::MODEL_KEY::COLOR];
    auto pin = link[FMH::MODEL_KEY::PIN].toInt();
    auto fav = link[FMH::MODEL_KEY::FAV].toInt();
    auto tags = link[FMH::MODEL_KEY::TAG].split(",", QString::SkipEmptyParts);
    auto updated = link[FMH::MODEL_KEY::MODIFIED];

    QVariantMap link_map =
    {
        {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], color},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::PIN], pin},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV], fav},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::MODIFIED], updated}
    };

    for(const auto &tg : tags)
        Tagging::getInstance()->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::LINKS], url, color);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::LINKS], link_map, {{FMH::MODEL_NAME[FMH::MODEL_KEY::LINK], url}} );
}

bool Links::remove(const int &index)
{
    emit this->preItemRemoved(index);

    auto linkUrl = this->links.at(index)[FMH::MODEL_KEY::LINK];
    QVariantMap link = {{FMH::MODEL_NAME[FMH::MODEL_KEY::LINK], linkUrl}};

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

    auto link = this->links.at(index)[FMH::MODEL_KEY::LINK];

    return Tagging::getInstance()->getAbstractTags(OWL::TABLEMAP[OWL::TABLE::LINKS], link);
}
