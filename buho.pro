QT *= core \
    quick \
    network \
    sql \
    qml \
    quickcontrols2


CONFIG += ordered
CONFIG += c++17

TARGET = buho
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 2
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += BUHO_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {

    message(Building for Linux KDE)
    LIBS += -lMauiKit

} else {

    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_TAGGING \
        COMPONENT_ACCOUNTS \
        COMPONENT_EDITOR \
        MAUIKIT_STYLE

    android {
        message(Building for Android)
        QT += androidextras

        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files
        DISTFILES += $$PWD/android_files/AndroidManifest.xml
        DEFINES *= ANDROID_OPENSSL
     }

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)


    DEFINES += STATIC_KIRIGAMI
    win32 {
        RC_ICONS = $$PWD/windows_files/buho.ico
    }

    macos {
        message(Building for Macos)
        ICON = $$PWD/macos_files/buho.icns
    }
}

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
    src/main.cpp \
    src/db/db.cpp \
    src/buho.cpp \
    src/syncing/syncer.cpp \
    src/syncing/notessyncer.cpp \
    src/syncing/bookssyncer.cpp \
    src/controllers/notes/notescontroller.cpp \
    src/controllers/books/bookscontroller.cpp \
    src/models/notes/notes.cpp \
    src/models/books/books.cpp \
    src/models/books/booklet.cpp \
    src/providers/nextnote.cpp

RESOURCES += \
    src/assets/imgs.qrc \
    src/qml.qrc

HEADERS += \
    src/db/db.h \
    src/buho.h \
    src/syncing/notessyncer.h \
    src/syncing/bookssyncer.h \
    src/syncing/syncer.h \
    src/controllers/notes/notescontroller.h \
    src/controllers/books/bookscontroller.h \
    src/utils/owl.h \
    src/models/notes/notes.h \
    src/models/books/books.h \
    src/models/books/booklet.h \
    src/providers/nextnote.h \
    src/providers/abstractnotesprovider.h

INCLUDEPATH += \
    src/utils/ \
    src/providers/ \
    src/syncing/ \
    src/controllers/ \
    src/

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

include($$PWD/install.pri)

ANDROID_ABIS = armeabi-v7a

