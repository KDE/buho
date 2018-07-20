import QtQuick 2.9
import QtQuick.Controls 2.3

Menu
{
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: true
    focus: true
    parent: ApplicationWindow.overlay

    margins: 1
    padding: 2

    signal deleteClicked()
    signal colorClicked()

    MenuItem
    {
        text: qsTr("Fav")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Pin")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Share")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Edit")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Export")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Delete")
        onTriggered:
        {
            deleteClicked()
            close()
        }
    }

    MenuItem
    {
        width: parent.width

        ColorsBar
        {
            width: parent.width
            size:  iconSizes.small
            onColorPicked: colorClicked(color)
        }
    }



}
