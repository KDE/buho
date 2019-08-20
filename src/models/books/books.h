#ifndef BOOKS_H
#define BOOKS_H

#include <QObject>
#include "owl.h"

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class Books : public MauiList
{
public:
    Books(QObject *parent = nullptr);
};

#endif // BOOKS_H
