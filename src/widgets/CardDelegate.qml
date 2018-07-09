import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    id: control
    property string noteColor : color ? color : "pink"
    property int cardWidth: Kirigami.Units.devicePixelRatio*200
    property int cardHeight: Kirigami.Units.devicePixelRatio*120
    width: cardWidth
    height: cardHeight

    background: Rectangle
    {
        color: "transparent"
    }

    DropShadow
    {
        anchors.fill: card
        visible: card.visible
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: card
    }

    Rectangle
    {
        id: card
        z: -999
        anchors.centerIn: control
        anchors.fill: control
        border.color: Qt.darker(noteColor, 1.2)

        color: noteColor
        radius: Kirigami.Units.devicePixelRatio*3
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0
        clip: true

        Label
        {
            id: title

            visible: title.text.length > 0
            Layout.leftMargin: space.medium
            Layout.topMargin: space.medium
            Layout.rightMargin: space.medium
            Layout.fillWidth: true
            text: model.title
            color: Qt.darker(model.color, 3)

            font.weight: Font.Bold
            font.bold: true
            font.pointSize: fontSizes.large
        }

        TextArea
        {
            id: body

            Layout.leftMargin: space.medium
            Layout.bottomMargin: space.medium
            Layout.rightMargin: space.medium
            Layout.topMargin: title.visible ? 0 : space.medium

            Layout.fillHeight: true
            Layout.fillWidth: true
            enabled: false
            text: model.body
            color: Qt.darker(model.color, 3)

            textFormat: TextEdit.RichText
            font.pointSize: fontSizes.big

            background: Rectangle
            {
                color: "transparent"
            }
        }

        Item
        {
            id: preview
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: control.height * 0.3
            Image
            {
                id: img
                visible: model.preview
                asynchronous: true
                height: parent.height
                width: parent.width
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectCrop
                source: model.preview || ""
            }
        }
    }

    function update(note)
    {
        title.text = note.title
        body.text = note.body
        noteColor = note.color
    }
}
