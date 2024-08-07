# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/utils

    ${CMAKE_CURRENT_SOURCE_DIR}/syncing

    ${CMAKE_CURRENT_SOURCE_DIR}/providers

    ${CMAKE_CURRENT_SOURCE_DIR}/controllers

    ${CMAKE_CURRENT_SOURCE_DIR}/models)

set(buho_SRCS
    main.cpp
    db/db.cpp
    models/notes/notes.cpp
    providers/nextnote.cpp
    syncing/syncer.cpp
    syncing/notessyncer.cpp
    controllers/notes/notescontroller.cpp
    utils/server.cpp
    qml.qrc)

set(buho_HDRS
    db/db.h
    utils/owl.h
    models/notes/notes.h
    providers/nextnote.h
    providers/abstractnotesprovider.h
    syncing/syncer.h
    syncing/notessyncer.h
    controllers/notes/notescontroller.h)

set(buho_ASSETS
    assets/imgs.qrc)

if(UNIX AND NOT ANDROID)
    qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/utils/server.h org.kde.Buho.xml)
    qt_add_dbus_adaptor(buho_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Buho.xml utils/server.h Server)
    qt_add_dbus_interface(buho_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Buho.xml buhointerface)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${buho_SRCS}
        ${buho_HDRS}
        ${buho_ASSETS}
        ${buho_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        ${buho_SRCS}
        ${buho_HDRS}
        ${buho_ASSETS}
        ${buho_QML_QRC}
        ${buho_dbus_SRCS})
endif()

if (ANDROID)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} Qt6::AndroidExtras OpenSSL::SSL Qt6::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt6::Widgets Qt6::DBus)
endif()

target_link_libraries(${PROJECT_NAME}
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::Accounts
    MauiKit4::TextEditor
    #[[tesseract]]
    Qt6::Sql
    Qt6::Quick
    Qt6::Qml
    Qt6::Network
    KF6::CoreAddons
    KF6::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS buho ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.buho.desktop DESTINATION ${KDE_INSTALL_APPDIR})

    #TODO: port to ecm_install_icons()
    install(FILES assets/buho.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
    install(FILES org.kde.buho.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
endif()
