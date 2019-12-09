project(buho)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#add_definitions( -Wall -O2 -fexceptions -std=c99)

include_directories(
#    ${CMAKE_CURRENT_SOURCE_DIR}/QGumboParser
#    ${CMAKE_CURRENT_BINARY_DIR}/QGumboParser

    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}/src

    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils
    ${CMAKE_CURRENT_BINARY_DIR}/src/utils

    ${CMAKE_CURRENT_SOURCE_DIR}/src/syncing
    ${CMAKE_CURRENT_BINARY_DIR}/src/syncing

    ${CMAKE_CURRENT_SOURCE_DIR}/src/providers
    ${CMAKE_CURRENT_BINARY_DIR}/src/providers
    )

set(buho_SRCS
    main.cpp
    src/db/db.cpp
    src/buho.cpp
    src/linker.cpp
    src/utils/htmlparser.cpp
    src/models/notes/notes.cpp
    src/models/links/links.cpp
    src/models/books/books.cpp
    src/models/books/booklet.cpp
    src/providers/nextnote.cpp
    src/syncing/syncer.cpp
    )

set(buho_HDRS
    src/db/db.h
    src/buho.h
    src/utils/owl.h
    src/linker.h
    src/utils/htmlparser.h
    src/models/notes/notes.h
    src/models/links/links.h
    src/models/books/books.h
    src/models/books/booklet.h
    src/providers/nextnote.h
    src/providers/abstractnotesprovider.h
    src/syncing/syncer.h
    )

set(buho_ASSETS
    qml.qrc
    assets/assets.qrc
    assets/icon-theme.qrc
    )

#set(qgumbo_SRCS

#    QGumboParser/qgumbodocument.cpp
#    QGumboParser/qgumbonode.cpp
#    QGumboParser/qgumboattribute.cpp
#    QGumboParser/gumbo-parser/src/attribute.c
#    QGumboParser/gumbo-parser/src/char_ref.c
#    QGumboParser/gumbo-parser/src/error.c
#    QGumboParser/gumbo-parser/src/parser.c
#    QGumboParser/gumbo-parser/src/string_buffer.c
#    QGumboParser/gumbo-parser/src/string_piece.c
#    QGumboParser/gumbo-parser/src/tag.c
#    QGumboParser/gumbo-parser/src/tokenizer.c
#    QGumboParser/gumbo-parser/src/utf8.c
#    QGumboParser/gumbo-parser/src/util.c
#    QGumboParser/gumbo-parser/src/vector.c
#    )

#set(qgumbo_HDRS
#    QGumboParser/qgumboattribute.h
#    QGumboParser/qgumbodocument.h
#    QGumboParser/HtmlTag.h
#    QGumboParser/qgumbonode.h
#    QGumboParser/gumbo-parser/src/attribute.h
#    QGumboParser/gumbo-parser/src/char_ref.h
#    QGumboParser/gumbo-parser/src/char_ref.rl
#    QGumboParser/gumbo-parser/src/error.h
#    QGumboParser/gumbo-parser/src/gumbo.h
#    QGumboParser/gumbo-parser/src/insertion_mode.h
#    QGumboParser/gumbo-parser/src/parser.h
#    QGumboParser/gumbo-parser/src/string_buffer.h
#    QGumboParser/gumbo-parser/src/string_piece.h
#    QGumboParser/gumbo-parser/src/tag_enum.h
#    QGumboParser/gumbo-parser/src/tag_gperf.h
#    QGumboParser/gumbo-parser/src/tag_sizes.h
#    QGumboParser/gumbo-parser/src/tag_strings.h
#    QGumboParser/gumbo-parser/src/token_type.h
#    QGumboParser/gumbo-parser/src/tokenizer_states.h
#    QGumboParser/gumbo-parser/src/tokenizer.h
#    QGumboParser/gumbo-parser/src/utf8.h
#    QGumboParser/gumbo-parser/src/util.h
#    QGumboParser/gumbo-parser/src/vector.h
#    )

add_executable(buho
    ${buho_SRCS}
    ${buho_HDRS}
    ${buho_ASSETS}
#    ${qgumbo_SRCS}
#    ${qgumbo_HDRS}
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)

    target_link_libraries(buho Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(buho src/buho.cpp)
else()
    find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica SyntaxHighlighting)
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)

    target_link_libraries(buho KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica KF5::SyntaxHighlighting)
endif()

if (TARGET create-apk-buho)
    set_target_properties(create-apk-buho PROPERTIES ANDROID_APK_DIR "${MAUIKIT_ANDROID_DIR}")
endif()

target_link_libraries(buho MauiKit Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg)

install(TARGETS buho ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.buho.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/buho.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
#install(FILES org.kde.buho.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
