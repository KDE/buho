QT += qml
QT += quick
QT += sql
QT += widgets
QT += quickcontrols2

CONFIG += c++11
CONFIG += ordered

TARGET = buho
TEMPLATE = app

DESTDIR = $$OUT_PWD/

linux:unix:!android {

    message(Building for Linux KDE)
    QT += webengine
    unix:!macx: LIBS += -lMauiKit

} else:android {

    message(Building helpers for Android)
    include($$PWD/android/android.pri)
    include($$PWD/android/openssl/openssl.pri)
    include($$PWD/mauikit/mauikit.pri)
    include($$PWD/3rdparty/kirigami/kirigami.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}


include($$PWD/QGumboParser/QGumboParser.pri)

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    main.cpp \
    src/db/db.cpp \
    src/db/dbactions.cpp \
    src/buho.cpp \
    src/documenthandler.cpp \
    src/linker.cpp \
    src/utils/htmlparser.cpp

RESOURCES += \
    qml.qrc \
    assets/assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


DISTFILES += \
    src/db/script.sql \
    src/utils/owl.js \

HEADERS += \
    src/db/db.h \
    src/db/dbactions.h \
    src/buho.h \
    src/utils/owl.h \
    src/documenthandler.h \
    src/linker.h \
    src/utils/htmlparser.h

INCLUDEPATH += \
    src/utils/ \
    src/

include($$PWD/install.pri)

