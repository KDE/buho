import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui
import org.buho.editor 1.0
import org.kde.kirigami 2.2 as Kirigami

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

    Connections
    {
        target: linker
        onPreviewReady:
        {
            previewReady = true
            fill(link)
        }
    }

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
            font.pointSize: fontSizes.large

            background: Rectangle
            {
                color: "transparent"
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: previewReady
            ListView
            {
                id: previewList
                anchors.fill: parent
                anchors.centerIn: parent
                clip: true
                snapMode: ListView.SnapOneItem
                orientation: ListView.Horizontal
                interactive: count > 1
                model: ListModel{}
                delegate: ItemDelegate
                {
                    height: previewList.height
                    width: previewList.width

                    background: Rectangle
                    {
                        color: "transparent"
                    }

                    Image
                    {
                        id: img
                        source: model.url
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        width: parent.width
                        height: parent.height
                        sourceSize.height: height
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }
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
            layoutDirection: Qt.RightToLeft
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
        title.text = note.title[0]
        populatePreviews(note.image)

        open()
    }

    function populatePreviews(imgs)
    {
        for(var i in imgs)
        {
            console.log("IMAGE:", imgs[i])
            previewList.model.append({url : imgs[i]})}
    }
}
