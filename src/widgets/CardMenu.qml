import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui

Maui.Menu
{
    implicitWidth: colorBar.implicitWidth + space.medium
    property bool isFav : false
    property bool isPin: false

    signal deleteClicked()
    signal colorClicked(color color)
    signal favClicked(int fav)
    signal pinClicked(int pin)
    signal copyClicked()

    Maui.MenuItem
    {
        text: qsTr(isFav? "UnFav" : "Fav")
        onTriggered:
        {
            favClicked(!isFav)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr(isPin? "UnPin" : "Pin")
        onTriggered:
        {
            pinClicked(!isPin)
            close()
        }
    }

      Maui.MenuItem
    {
        text: qsTr("Export")
        onTriggered:
        {
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Copy")
        onTriggered:
        {
            copyClicked()
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Delete")
        onTriggered:
        {
            deleteClicked()
            close()
        }
    }

    MenuSeparator
    {

    }

    Maui.MenuItem
    {
        width: parent.width
        height: rowHeight

        ColorsBar
        {
            id: colorBar
            anchors.centerIn: parent
            onColorPicked:
            {
                colorClicked(color)
                close()
            }
        }
    }
}
