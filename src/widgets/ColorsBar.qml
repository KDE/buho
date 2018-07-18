import QtQuick 2.0
import QtQuick.Controls 2.2

Row
{
    signal colorPicked(color color)
    anchors.verticalCenter: parent.verticalCenter
    spacing: space.medium

    Rectangle
    {
        color:"#ffded4"
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }

    Rectangle
    {
        color:"#d3ffda"
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }

    Rectangle
    {
        color:"#caf3ff"
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }

    Rectangle
    {
        color:"#dbd8ff"
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }

    Rectangle
    {
        color:"#ffcdf4"
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }

    Rectangle
    {
        color: viewBackgroundColor
        anchors.verticalCenter: parent.verticalCenter
        height: iconSizes.medium
        width: height
        radius: Math.max(height, width)
        border.color: borderColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: colorPicked(parent.color)
        }
    }
}
