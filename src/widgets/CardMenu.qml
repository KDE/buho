import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Menu
{
    implicitWidth: colorBar.implicitWidth + space.medium
    property bool isFav : false
    property bool isPin: false

    signal deleteClicked()
    signal colorClicked(color color)
    signal favClicked(int fav)
    signal pinClicked(int pin)
    signal copyClicked()

    MenuItem
    {
        text: qsTr(isFav? "UnFav" : "Fav")
        onTriggered:
        {
            favClicked(!isFav)
            close()
        }
    }

    MenuItem
    {
        text: qsTr(isPin? "UnPin" : "Pin")
        onTriggered:
        {
            pinClicked(!isPin)
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
        text: qsTr("Copy")
        onTriggered:
        {
            copyClicked()
            close()
        }
    }

    MenuItem
    {
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
