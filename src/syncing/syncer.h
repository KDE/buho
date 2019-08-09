#ifndef SYNCER_H
#define SYNCER_H

#include <QObject>

/**
 * @brief The Syncer class
 * This interfaces between local storage and cloud
 * Its work is to try and keep thing synced and do the background work on updating notes
 * from local to cloud and viceversa.
 * This interface should be used to handle the whol offline and online work,
 * instead of manually inserting to the db or the cloud providers
 */

class Syncer : public QObject
{
    Q_OBJECT
public:
    explicit Syncer(QObject *parent = nullptr);

signals:

public slots:
};

#endif // SYNCER_H
