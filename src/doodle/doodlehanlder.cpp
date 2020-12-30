#include "doodlehanlder.h"

#include "tesseract/baseapi.h"
#include "tesseract/ocrclass.h"
#include <QDebug>
#include <QImage>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <leptonica/allheaders.h>
#include <string>

DoodleHanlder::DoodleHanlder(QObject *parent)
    : QObject(parent)
{
}

QString DoodleHanlder::getText(const QString &imagePath)
{
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
    api->Init(NULL, "eng", tesseract::OEM_LSTM_ONLY);
    api->SetPageSegMode(tesseract::PSM_AUTO);
    api->SetVariable("debug_file", "tesseract.log");

    //    char *text;
    QImage image(imagePath);

    if (image.isNull())
        return "";

    qDebug() << image;

    QImage g = image.convertToFormat(QImage::Format_Grayscale8);
    qDebug() << g;
    if (g.isNull())
        return "";

    api->SetImage(g.bits(), g.width(), g.height(), 1, g.bytesPerLine());

    QString outText = QString::fromStdString(api->GetUTF8Text());
    qDebug() << outText;
    api->End();
    //    pixDestroy(&image);
    return outText;
}
