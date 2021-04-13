import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.0 as Maui

Row
{
    spacing: Maui.Style.space.medium

    property color currentColor
    property int size : Maui.Style.iconSizes.medium
    signal colorPicked(string color)

    Repeater
    {
        model: ["#ffded4", "#d3ffda", "#caf3ff", "#dbd8ff", "#ffcdf4"]

        Rectangle
        {
            color: modelData
            anchors.verticalCenter: parent.verticalCenter
            height: size
            width: size
            radius: color == currentColor ? Maui.Style.radiusV : size
            border.color: Qt.lighter(color, 2.5)

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    currentColor = parent.color
                    colorPicked(currentColor)
                }
            }
        }
    }

    Kirigami.Icon
    {
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height

        source: "edit-clear"
        color: Kirigami.Theme.textColor

        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                currentColor = ""
                colorPicked(currentColor)
            }
        }
    }
}
