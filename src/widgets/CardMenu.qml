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

    MenuItem
    {
        icon.name: "love"
        text: qsTr(isFav? "UnFav" : "Fav")
        onTriggered:
        {
            favClicked(!isFav)
            close()
        }
    }

    MenuItem
    {
        icon.name: "pin"
        text: qsTr(isPin? "UnPin" : "Pin")
        onTriggered:
        {
            pinClicked(!isPin)
            close()
        }
    }

      MenuItem
    {
        icon.name: "document-export"
        text: qsTr("Export")
        onTriggered:
        {
            close()
        }
    }

    MenuItem
    {
        icon.name : "edit-copy"
        text: qsTr("Copy")
        onTriggered:
        {
            copyClicked()
            close()
        }
    }

    MenuSeparator
    {

    }


    MenuItem
    {
        icon.name: "edit-delete"
        text: qsTr("Remove")
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            deleteClicked()
            close()
        }
    }

    MenuSeparator
    {

    }

    MenuItem
    {
        width: parent.width
        height: Maui.Style.rowHeight

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
