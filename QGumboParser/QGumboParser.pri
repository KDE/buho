CONFIG += staticlib c++11
QMAKE_CFLAGS += -std=c99

HEADERS += \
    $$PWD/qgumboattribute.h \
    $$PWD/qgumbodocument.h \
    $$PWD/HtmlTag.h \
    $$PWD/qgumbonode.h \
    $$PWD/gumbo-parser/src/attribute.h \
    $$PWD/gumbo-parser/src/char_ref.h \
    $$PWD/gumbo-parser/src/char_ref.rl \
    $$PWD/gumbo-parser/src/error.h \
    $$PWD/gumbo-parser/src/gumbo.h \
    $$PWD/gumbo-parser/src/insertion_mode.h \
    $$PWD/gumbo-parser/src/parser.h \
    $$PWD/gumbo-parser/src/string_buffer.h \
    $$PWD/gumbo-parser/src/string_piece.h \
    $$PWD/gumbo-parser/src/tag_enum.h \
    $$PWD/gumbo-parser/src/tag_gperf.h \
    $$PWD/gumbo-parser/src/tag_sizes.h \
    $$PWD/gumbo-parser/src/tag_strings.h \
    $$PWD/gumbo-parser/src/token_type.h \
    $$PWD/gumbo-parser/src/tokenizer_states.h \
    $$PWD/gumbo-parser/src/tokenizer.h \
    $$PWD/gumbo-parser/src/utf8.h \
    $$PWD/gumbo-parser/src/util.h \
    $$PWD/gumbo-parser/src/vector.h

SOURCES += \
    $$PWD/qgumbodocument.cpp \
    $$PWD/qgumbonode.cpp \
    $$PWD/qgumboattribute.cpp \
    $$PWD/gumbo-parser/src/attribute.c \
    $$PWD/gumbo-parser/src/char_ref.c \
    $$PWD/gumbo-parser/src/error.c \
    $$PWD/gumbo-parser/src/parser.c \
    $$PWD/gumbo-parser/src/string_buffer.c \
    $$PWD/gumbo-parser/src/string_piece.c \
    $$PWD/gumbo-parser/src/tag.c \
    $$PWD/gumbo-parser/src/tokenizer.c \
    $$PWD/gumbo-parser/src/utf8.c \
    $$PWD/gumbo-parser/src/util.c \
    $$PWD/gumbo-parser/src/vector.c

INCLUDEPATH += \
    $$PWD

DEPENDPATH += \
    $$PWD

DISTFILES += \
    $$PWD/gumbo-parser/src/tag.in
