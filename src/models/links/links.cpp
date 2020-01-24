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
    __model[FMH::MODEL_KEY::PREVIEW] = QUrl(__model[FMH::MODEL_KEY::PREVIEW]).toString();

    __model = FMH::filterModel(__model, {FMH::MODEL_KEY::URL,
                                         FMH::MODEL_KEY::TITLE,
                                         FMH::MODEL_KEY::PREVIEW,
                                         FMH::MODEL_KEY::COLOR,
                                         FMH::MODEL_KEY::FAVORITE,
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


bool Links::update(const QVariantMap &data, const int &index)
{
    if(index < 0 || index >= this->links.size())
        return false;

    const auto index_ = this->mappedIndex(index);

    this->links[index_] = this->links[index_].unite(FMH::toModel(data));

    this->links[index_][FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString(Qt::TextDate);
   this->links[index_][FMH::MODEL_KEY::PREVIEW] = QUrl(this->links[index_][FMH::MODEL_KEY::PREVIEW]).toString();

    for(const auto &tg :  this->links[index][FMH::MODEL_KEY::TAG].split(",", QString::SkipEmptyParts))
        Tagging::getInstance()->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::LINKS], this->links[index_][FMH::MODEL_KEY::URL]);


    const auto map = FMH::toMap(FMH::filterModel(this->links[index_], {FMH::MODEL_KEY::URL,
                                                                      FMH::MODEL_KEY::TITLE,
                                                                      FMH::MODEL_KEY::PREVIEW,
                                                                      FMH::MODEL_KEY::FAVORITE,
                                                                      FMH::MODEL_KEY::MODIFIED}));

    if(this->db->update(OWL::TABLEMAP[OWL::TABLE::LINKS], map, {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], this->links[index][FMH::MODEL_KEY::URL]}} ))
    {
        this->updateModel(index, FMH::modelRoles(this->links[index_]));
        return true;
    }
    return false;
}

bool Links::remove(const int &index)
{    
    if(index < 0 || index >= this->links.size())
        return false;

    const auto index_ = this->mappedIndex(index);

    emit this->preItemRemoved(index_);

    auto linkUrl = this->links.at(index_)[FMH::MODEL_KEY::LINK];
    QVariantMap link = {{FMH::MODEL_NAME[FMH::MODEL_KEY::LINK], linkUrl}};

    if(this->db->remove(OWL::TABLEMAP[OWL::TABLE::LINKS], link))
    {
        this->links.removeAt(index_);
        emit this->postItemRemoved();
        return true;
    }

    return false;
}

