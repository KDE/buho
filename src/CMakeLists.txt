include_directories(
#    ${CMAKE_CURRENT_SOURCE_DIR}/QGumboParser
#    ${CMAKE_CURRENT_BINARY_DIR}/QGumboParser

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
    linker.cpp
    utils/htmlparser.cpp
    models/notes/notes.cpp
    models/links/links.cpp
    models/books/books.cpp
    models/books/booklet.cpp
    providers/nextnote.cpp
    syncing/syncer.cpp
    controllers/notes/notescontroller.cpp
    controllers/books/bookscontroller.cpp
    controllers/links/linkscontroller.cpp
    )

set(buho_HDRS
    db/db.h
    buho.h
    utils/owl.h
    linker.h
    utils/htmlparser.h
    models/notes/notes.h
    models/links/links.h
    models/books/books.h
    models/books/booklet.h
    providers/nextnote.h
    providers/abstractnotesprovider.h
    syncing/syncer.h
    controllers/notes/notescontroller.h
    controllers/books/bookscontroller.h
    controllers/links/linkscontroller.h
    )

set(buho_ASSETS
    qml.qrc
    assets/assets.qrc
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

if(ANDROID)
    target_link_libraries(buho Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(buho buho.cpp)
endif()

target_link_libraries(buho MauiKit Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg Qt5::WebView)
target_link_libraries(buho KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica KF5::SyntaxHighlighting)

install(TARGETS buho ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.buho.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/buho.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
#install(FILES org.kde.buho.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
