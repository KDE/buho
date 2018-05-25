import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui

Popup
{
    parent: ApplicationWindow.overlay
    height: parent.height * (isMobile ?  0.8 : 0.7)
    width: parent.width * (isMobile ?  0.9 : 0.7)

    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)

    padding: 1

    Rectangle
    {
        id: bg
        color: "#ffffe6"
        z: -1
        anchors.fill: parent
    }

    ColumnLayout
    {
        anchors.fill: parent

        Maui.ToolBar
        {
            Layout.fillWidth: true

            leftContent: [
                Maui.ToolButton
                {
                    iconName: "format-text-bold"
                },

                Maui.ToolButton
                {
                    iconName: "format-text-italic-symbolic"
                },

                Maui.ToolButton
                {
                    iconName: "format-text-underline-symbolic"
                },

                Maui.ToolButton
                {
                    iconName: "format-text-uppercase"
                }

            ]

            rightContent: Maui.ToolButton
            {
                iconName: "overflow-menu"
            }

        }

        TextField
        {
            id: title
            Layout.fillWidth: true
            Layout.margins: space.medium
            height: 24
            placeholderText: qsTr("Title")
            font.weight: Font.Bold
            font.bold: true
            background: Rectangle
            {
                color: "transparent"
            }
        }

        ScrollView
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: space.medium

            TextArea
            {
                id: body

                placeholderText: qsTr("Body")

                background: Rectangle
                {
                    color: "transparent"
                }
            }
        }

        Row
        {
            Layout.fillWidth: true
            width: parent.width
            Layout.margins: space.medium
            Layout.alignment: Qt.AlignRight
            spacing: space.medium
            Button
            {
                id: save
                text: qsTr("Save")
                onClicked:
                {
                    if(owl.insertNote(title.text, body.text))
                        close()
                }
            }

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked:
                {
                    clearNote()
                    close()
                }
            }
        }
    }
    onOpened: clearNote()


    function clearNote()
    {
        title.clear()
        body.clear()
    }
}
