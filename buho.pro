QT += qml
QT += quick
QT += sql
QT += widgets
QT += quickcontrols2

CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    main.cpp \
    src/db/db.cpp \
    src/db/dbactions.cpp \
    src/buho.cpp

RESOURCES += \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


include(mauikit/mauikit.pri)

linux:unix:!android {

    message(Building for Linux KDE)

} else:android {

    message(Building helpers for Android)
    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/android/android.pri)
    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

DISTFILES += \
    src/db/script.sql \
    src/utils/owl.js

HEADERS += \
    src/db/db.h \
    src/db/dbactions.h \
    src/buho.h \
    src/utils/owl.h

