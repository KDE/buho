import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Row
{
    signal colorPicked(string color)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Maui.Style.space.medium
    property string currentColor
    property int size : Maui.Style.iconSizes.medium

    Rectangle
    {
        color:"#ffded4"
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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

    Rectangle
    {
        color:"#d3ffda"
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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

    Rectangle
    {
        color:"#caf3ff"
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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

    Rectangle
    {
        color:"#dbd8ff"
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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

    Rectangle
    {
        color:"#ffcdf4"
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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

    Rectangle
    {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
        anchors.verticalCenter: parent.verticalCenter
        height: size
        width: height
        radius: Maui.Style.radiusV
        border.color: Qt.darker(color, 1.7)

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
