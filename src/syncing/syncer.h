#ifndef SYNCER_H
#define SYNCER_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

#include "abstractnotesprovider.h"

/**
 * @brief The Syncer class
 * This interfaces between local storage and cloud
 * Its work is to try and keep thing synced and do the background work on updating notes
 * from local to cloud and viceversa.
 * This interface should be used to handle the whol offline and online work,
 * instead of manually inserting to the db or the cloud providers
 */

struct STATE {
    enum TYPE : uint { LOCAL, REMOTE };

    enum STATUS : uint { OK, ERROR };

    TYPE type;
    STATUS status;
    QString msg = QString();
};

class Syncer : public QObject
{
    Q_OBJECT

public:
    explicit Syncer(QObject *parent = nullptr);
    /**
     * @brief setProviderAccount
     * sets the credentials to the current account
     * for the current provider being used
     * @param account
     * the account data represented by FMH::MODEL
     * where the valid keys are:
     * FMH::MODEL_KEY::USER user name
     * FMH::MODEL_KEY::PASSWORD users password
     * FMH::MODEL_KEY::PROVIDER the url to the provider server
     */
    void setAccount(const FMH::MODEL &account);

    /**
     * @brief setProvider
     * sets the provider interface
     * this allows to change the provider source
     * @param provider
     * the provider must inherit the asbtract class AbstractNotesProvider.
     * The value passed is then moved to this class private property Syncer::provider
     */
    void setProvider(AbstractNotesProvider *provider);

    AbstractNotesProvider &getProvider() const
    {
        return *this->m_provider;
    }

    bool validProvider() const
    {
        return this->m_provider && this->m_provider->isValid();
    }

private:
    /**
     * @brief server
     * Abstract instance to the online server to perfom CRUD actions
     */
    AbstractNotesProvider *m_provider;
    virtual void setConections() = 0;
};

#endif // SYNCER_H
