import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui
import org.buho.editor 1.0

Popup
{
    parent: ApplicationWindow.overlay
    height: parent.height * (isMobile ?  0.8 : 0.7)
    width: parent.width * (isMobile ?  0.9 : 0.7)

    property string selectedColor : "#ffffe6"
    signal noteSaved(var note)
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)

    padding: 1

    Rectangle
    {
        id: bg
        color: selectedColor
        z: -1
        anchors.fill: parent
    }

    ColumnLayout
    {
        id: content
        anchors.fill: parent

        Maui.ToolBar
        {
            position: ToolBar.Header
            z: 999
            Layout.fillWidth: true

            leftContent: [
                Maui.ToolButton
                {
                    iconName: "format-text-bold"
                    focusPolicy: Qt.TabFocus
                    iconColor: checked ? highlightColor : textColor
                    checkable: true
                    checked: document.bold
                    onClicked: document.bold = !document.bold
                },

                Maui.ToolButton
                {
                    iconName: "format-text-italic-symbolic"
                    iconColor: checked ? highlightColor : textColor
                    focusPolicy: Qt.TabFocus
                    checkable: true
                    checked: document.italic
                    onClicked: document.italic = !document.italic
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

            rightContent: Row
            {
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
                        onClicked: selectedColor = parent.color
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
                        onClicked: selectedColor = parent.color
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
                        onClicked: selectedColor = parent.color
                    }
                }

                Rectangle
                {
                    color:"#ccc1ff"
                    anchors.verticalCenter: parent.verticalCenter
                    height: iconSizes.medium
                    width: height
                    radius: Math.max(height, width)
                    border.color: borderColor

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: selectedColor = parent.color
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
                        onClicked: selectedColor = parent.color
                    }
                }

                Maui.ToolButton

                {
                    iconName: "overflow-menu"
                }
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
            color: Qt.darker(selectedColor, 2.5)
            background: Rectangle
            {
                color: "transparent"
            }
        }

        DocumentHandler
        {
            id: document
            document: body.textDocument
            cursorPosition: body.cursorPosition
            selectionStart: body.selectionStart
            selectionEnd: body.selectionEnd
            // textColor: TODO
            //            onLoaded: {
            //                body.text = text
            //            }
            onError: {
                body.text = message
                body.visible = true
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
                selectByKeyboard :!isMobile
                selectByMouse : !isMobile
                textFormat : TextEdit.AutoText
                color: Qt.darker(selectedColor, 2.5)

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
                    if(body.text.length > 0)
                        noteSaved({
                                      title: title.text,
                                      body: body.text,
                                      color: selectedColor,
                                      tags: ""
                                  })
                    clearNote()
                    close()
                }
            }

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked:
                {
                    close()
                    clearNote()
                }
            }

        }
    }

    onOpened: body.forceActiveFocus()


    function clearNote()
    {
        title.clear()
        body.clear()
    }

    function fill(note)
    {
        document.load("qrc:/texteditor.html")
        title.text = note.title
        body.text = note.body
        selectedColor =  note.color

        open()
    }
}
