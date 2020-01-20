import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Menu
{
    implicitWidth: colorBar.implicitWidth + Maui.Style.space.medium
    property bool isFav : false
    property bool isPin: false

    signal deleteClicked()
    signal colorClicked(string color)
    signal favClicked(int favorite)
    signal pinClicked(int pin)
    signal copyClicked()


}
