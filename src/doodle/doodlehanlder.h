#pragma once

#include <QObject>
#include <QString>
//#include <opencv4/opencv2/opencv.hpp>

class DoodleHanlder : public QObject
{
    Q_OBJECT
public:
    explicit DoodleHanlder(QObject *parent = nullptr);

public Q_SLOTS:
    QString getText(const QString &imagePath);

};
