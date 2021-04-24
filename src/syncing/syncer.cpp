#include "syncer.h"
#include "abstractnotesprovider.h"
#include "db/db.h"

#include <MauiKit/Core/mauiaccounts.h>

Syncer::Syncer(QObject *parent)
    : QObject(parent)
    , m_provider(nullptr) // online service handler
{
    connect(MauiAccounts::instance(), &MauiAccounts::currentAccountChanged, [&](QVariantMap currentAccount) {

        qDebug() << "Current account changed" << currentAccount;
        this->setAccount(FMH::toModel(currentAccount));
    });
}

void Syncer::setAccount(const FMH::MODEL &account)
{
    if (this->m_provider)
        this->m_provider->setCredentials(account);
}

void Syncer::setProvider(AbstractNotesProvider *provider)
{
    this->m_provider = std::move(provider);
    this->m_provider->setParent(this);
    this->m_provider->disconnect();
    this->setConections();
}
