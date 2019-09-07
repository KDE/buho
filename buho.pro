QT += qml
QT += quick
QT += sql
QT += widgets
QT += quickcontrols2

CONFIG += ordered
CONFIG += c++17
QMAKE_LINK += -nostdlib++

TARGET = buho
TEMPLATE = app

DESTDIR = $$OUT_PWD/

linux:unix:!android {

    message(Building for Linux KDE)
    QT += webengine
    LIBS += -lMauiKit

} else:android {

    message(Building helpers for Android)
    QT += androidextras webview
#    include($$PWD/3rdparty/openssl/openssl.pri)

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}
include($$PWD/QGumboParser/QGumboParser.pri)

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    main.cpp \
    src/db/db.cpp \
    src/buho.cpp \
    src/linker.cpp \
    src/syncing/syncer.cpp \
    src/utils/htmlparser.cpp \
    src/models/notes/notes.cpp \
    src/models/books/books.cpp \
    src/models/books/booklet.cpp \
    src/models/links/links.cpp \
    src/providers/nextnote.cpp \

RESOURCES += \
    qml.qrc \
    assets/assets.qrc

HEADERS += \
    src/db/db.h \
    src/buho.h \
    src/syncing/syncer.h \
    src/utils/owl.h \
    src/linker.h \
    src/utils/htmlparser.h \
    src/models/notes/notes.h \
    src/models/books/books.h \
    src/models/books/booklet.h \
    src/models/links/links.h \
    src/providers/nextnote.h \
    src/providers/abstractnotesprovider.h

INCLUDEPATH += \
    src/utils/ \
    src/providers/ \
    src/syncing/ \
    src/

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    3rdparty/mauikit/src/android/AndroidManifest.xml \
    3rdparty/mauikit/src/android/AndroidManifest.xml \
    3rdparty/mauikit/src/android/build.gradle \
    3rdparty/mauikit/src/android/build.gradle \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.jar \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.jar \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.properties \
    3rdparty/mauikit/src/android/gradle/wrapper/gradle-wrapper.properties \
    3rdparty/mauikit/src/android/gradlew \
    3rdparty/mauikit/src/android/gradlew \
    3rdparty/mauikit/src/android/gradlew.bat \
    3rdparty/mauikit/src/android/gradlew.bat \
    3rdparty/mauikit/src/android/res/values/libs.xml \
    3rdparty/mauikit/src/android/res/values/libs.xml \
    src/db/script.sql \

include($$PWD/install.pri)

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/3rdparty/mauikit/src/android
}

