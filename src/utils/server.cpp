#include "server.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QQmlApplicationEngine>

#include <MauiKit3/FileBrowsing/fmstatic.h>

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
#include "buhointerface.h"
#include "buhoadaptor.h"

QVector<QPair<QSharedPointer<OrgKdeBuhoActionsInterface>, QStringList>> AppInstance::appInstances(const QString& preferredService)
{
    QVector<QPair<QSharedPointer<OrgKdeBuhoActionsInterface>, QStringList>> dolphinInterfaces;

    if (!preferredService.isEmpty())
    {
        QSharedPointer<OrgKdeBuhoActionsInterface> preferredInterface(
                    new OrgKdeBuhoActionsInterface(preferredService,
                                                   QStringLiteral("/Actions"),
                                                   QDBusConnection::sessionBus()));

        qDebug() << "IS PREFRFRED INTERFACE VALID?" << preferredInterface->isValid() << preferredInterface->lastError().message();
        if (preferredInterface->isValid() && !preferredInterface->lastError().isValid()) {
            dolphinInterfaces.append(qMakePair(preferredInterface, QStringList()));
        }
    }

    // Look for dolphin instances among all available dbus services.
    QDBusConnectionInterface *sessionInterface = QDBusConnection::sessionBus().interface();
    const QStringList dbusServices = sessionInterface ? sessionInterface->registeredServiceNames().value() : QStringList();
    // Don't match the service without trailing "-" (unique instance)
    const QString pattern = QStringLiteral("org.kde.buho-");

    // Don't match the pid without leading "-"
    const QString myPid = QLatin1Char('-') + QString::number(QCoreApplication::applicationPid());

    for (const QString& service : dbusServices)
    {
        if (service.startsWith(pattern) && !service.endsWith(myPid))
        {
            qDebug() << "EXISTING INTANCES" << service;

            // Check if instance can handle our URLs
            QSharedPointer<OrgKdeBuhoActionsInterface> interface(
                        new OrgKdeBuhoActionsInterface(service,
                                                       QStringLiteral("/Actions"),
                                                       QDBusConnection::sessionBus()));
            if (interface->isValid() && !interface->lastError().isValid())
            {
                dolphinInterfaces.append(qMakePair(interface, QStringList()));
            }
        }
    }

    return dolphinInterfaces;
}

bool AppInstance::attachToExistingInstance(bool newNote, const QString& content)
{
    bool attached = false;

    auto dolphinInterfaces = appInstances("");
    if (dolphinInterfaces.isEmpty())
    {
        return attached;
    }

    for (const auto& interface: qAsConst(dolphinInterfaces))
    {
        if(newNote)
        {
            auto reply = interface.first->newNote(content);
            reply.waitForFinished();

            if (!reply.isError())
            {
                interface.first->activateWindow();
                attached = true;
                break;
            }
        }else
        {
            auto reply = interface.first->activateWindow();
            reply.waitForFinished();

            if (!reply.isError())
            {
                attached = true;
                break;
            }
        }
    }

    return attached;
}

bool AppInstance::registerService()
{
    QDBusConnectionInterface *iface = QDBusConnection::sessionBus().interface();

    auto registration = iface->registerService(QStringLiteral("org.kde.buho-%1").arg(QCoreApplication::applicationPid()),
                                               QDBusConnectionInterface::ReplaceExistingService,
                                               QDBusConnectionInterface::DontAllowReplacement);

    if (!registration.isValid())
    {
        qWarning("2 Failed to register D-Bus service \"%s\" on session bus: \"%s\"",
                 qPrintable("org.kde.buho"),
                 qPrintable(registration.error().message()));
        return false;
    }

    return true;
}

#endif


Server::Server(QObject *parent) : QObject(parent)
  , m_qmlObject(nullptr)
{
#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    new ActionsAdaptor(this);
    if(!QDBusConnection::sessionBus().registerObject(QStringLiteral("/Actions"), this))
    {
        qDebug() << "FAILED TO REGISTER BACKGROUND DBUS OBJECT";
        return;
    }
#endif
}

void Server::setQmlObject(QObject *object)
{
    if(!m_qmlObject)
    {
        m_qmlObject = object;
    }
}

void Server::activateWindow()
{
    if(m_qmlObject)
    {
        qDebug() << "ACTIVET WINDOW FROM C++";
        auto window = qobject_cast<QQuickWindow *>(m_qmlObject);
        if (window)
        {
            qDebug() << "Trying to raise wndow";
            window->raise();
            window->requestActivate();
        }
    }
}

void Server::quit()
{
    QCoreApplication::quit();
}

void Server::newNote(const QString &content)
{
    if(m_qmlObject)
    {

        QMetaObject::invokeMethod(m_qmlObject, "newNote",
                                  Q_ARG(QString, content));

    }
}

