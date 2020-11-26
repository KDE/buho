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
    doodle/doodlehanlder.cpp
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
    doodle/doodlehanlder.h
    )

set(buho_ASSETS
    qml.qrc
    assets/imgs.qrc
    )

add_executable(buho
    ${buho_SRCS}
    ${buho_HDRS}
    ${buho_ASSETS}
    )

if(ANDROID)
    target_link_libraries(buho Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(buho buho.cpp)
endif()

target_link_libraries(buho MauiKit tesseract Qt5::Sql Qt5::Qml Qt5::Svg Qt5::WebView)
target_link_libraries(buho KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica KF5::SyntaxHighlighting)

install(TARGETS buho ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.buho.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/buho.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
#install(FILES org.kde.buho.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
