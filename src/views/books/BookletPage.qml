import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Item
{
    id: control

    signal exit()

    Maui.Page
    {
        id: _page
        anchors.fill: parent
        anchors.rightMargin: _drawer.modal === false ? _drawer.contentItem.width * _drawer.position : 0

        headBar.leftContent: [
            ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.exit()
        },

        TextField
           {
               id: title
               Layout.fillWidth: true
               Layout.margins: space.medium
               placeholderText: qsTr("New chapter...")
               font.weight: Font.Bold
               font.bold: true
               font.pointSize: fontSizes.large
               //            Kirigami.Theme.backgroundColor: selectedColor
               //            Kirigami.Theme.textColor: Qt.darker(selectedColor, 2.5)
               //            color: fgColor
               background: Rectangle
               {
                   color: "transparent"
               }
           }
        ]


        Maui.Editor
        {
            anchors.fill: parent
        }

        Maui.Dialog
        {
            id: _newChapter

            title: qsTr("New Chapter")
            message: qsTr("Create a new chapter for your current book. Give it a title")
            entryField: true
        }

        Kirigami.OverlayDrawer
        {
            id: _drawer
            edge: Qt.RightEdge
            width: Kirigami.Units.gridUnit * 16
            height: parent.height - headBar.height
            y: headBar.height
            modal: !isWide

            Rectangle
            {
                z: 999
                anchors.bottom: parent.bottom
                anchors.margins: toolBarHeight
                anchors.horizontalCenter: parent.horizontalCenter
                height: toolBarHeight
                width: height

                color: Kirigami.Theme.highlightColor
                radius: radiusV

                ToolButton
                {
                    anchors.centerIn: parent
                    icon.name: "list-add"
                    icon.color: Qt.darker(parent.color, 2)

                    onClicked: _newChapter.open()
                }
            }
        }
    }

}
