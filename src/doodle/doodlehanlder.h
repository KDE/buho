#ifndef DOODLEHANLDER_H
#define DOODLEHANLDER_H

#include <QObject>
#include <QString>
//#include <opencv4/opencv2/opencv.hpp>

class DoodleHanlder : public QObject
{
    Q_OBJECT
public:
    explicit DoodleHanlder(QObject *parent = nullptr);

public slots:
    QString getText(const QString &imagePath);

signals:
};

#endif // DOODLEHANLDER_H
