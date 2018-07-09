import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui
import org.buho.editor 1.0

Popup
{
    parent: ApplicationWindow.overlay
    height: previewReady ? parent.height * (isMobile ?  0.8 : 0.7) :
                            toolBarHeight
    width: parent.width * (isMobile ?  0.9 : 0.7)

    signal linkSaved(var note)

    property bool previewReady : false
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)

    padding: 1

    Rectangle
    {
        id: bg
        color: "transparent"
        z: -1
        anchors.fill: parent
    }

    ColumnLayout
    {
        id: content
        anchors.fill: parent

        TextField
        {
            id: link
            Layout.fillWidth: true
            Layout.margins: space.medium
            height: 24
            placeholderText: qsTr("URL")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: fontSizes.large
            background: Rectangle
            {
                color: "transparent"
            }

            onAccepted: linker.extract(link.text)
        }

        TextField
        {
            id: title
            visible: previewReady
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
            visible: previewReady
            TextArea
            {
                id: body

                placeholderText: qsTr("Body")
                textFormat : TextEdit.AutoText
                enabled: false

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
            visible: previewReady
            Button
            {
                id: save
                text: qsTr("Save")
                onClicked:
                {
                    linker.extract(link.text)
                    clear()
                }

            }

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked:  clear()
            }
        }
    }


    function clear()
    {
        title.clear()
        body.clear()
        close()

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
