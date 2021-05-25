# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/utils
    ${CMAKE_CURRENT_BINARY_DIR}/utils

    ${CMAKE_CURRENT_SOURCE_DIR}/syncing
    ${CMAKE_CURRENT_BINARY_DIR}/syncing

    ${CMAKE_CURRENT_SOURCE_DIR}/providers
    ${CMAKE_CURRENT_BINARY_DIR}/providers

    ${CMAKE_CURRENT_SOURCE_DIR}/controllers
    ${CMAKE_CURRENT_BINARY_DIR}/controllers

    ${CMAKE_CURRENT_SOURCE_DIR}/models
    ${CMAKE_CURRENT_BINARY_DIR}/models
    )

set(buho_SRCS
    main.cpp
    db/db.cpp
    buho.cpp
    models/notes/notes.cpp
    models/books/books.cpp
    models/books/booklet.cpp
    providers/nextnote.cpp
    syncing/syncer.cpp
    syncing/bookssyncer.cpp
    syncing/notessyncer.cpp
    controllers/notes/notescontroller.cpp
    controllers/books/bookscontroller.cpp
    #    doodle/doodlehanlder.cpp
    )

set(buho_HDRS
    db/db.h
    buho.h
    utils/owl.h
    models/notes/notes.h
    models/books/books.h
    models/books/booklet.h
    providers/nextnote.h
    providers/abstractnotesprovider.h
    syncing/syncer.h
    syncing/bookssyncer.h
    syncing/notessyncer.h
    controllers/notes/notescontroller.h
    controllers/books/bookscontroller.h
    #    doodle/doodlehanlder.h
    )

set(buho_ASSETS
    qml.qrc
    assets/imgs.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${buho_SRCS}
        ${buho_HDRS}
        ${buho_ASSETS} )
else()
    add_executable(${PROJECT_NAME}
        ${buho_SRCS}
        ${buho_HDRS}
        ${buho_ASSETS})
endif()

if (ANDROID)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2 OpenSSL::SSL)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing MauiKit::Accounts #[[tesseract]] Qt5::Sql Qt5::Qml Qt5::Svg Qt5::Concurrent  KF5::SyntaxHighlighting KF5::CoreAddons KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS buho ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.buho.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

    #TODO: port to ecm_install_icons()
    install(FILES assets/buho.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
    install(FILES org.kde.buho.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
endif()
