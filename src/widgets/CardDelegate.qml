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
    property int cardRadius: Kirigami.Units.devicePixelRatio*4
    width: cardWidth
    height: cardHeight
    hoverEnabled: !isMobile
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
        radius: cardRadius
    }

    Rectangle
    {
        anchors.fill: parent
        color: hovered? "#333" :  "transparent"
        z: 999
        opacity: 0.3
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
            elide: Qt.ElideRight

            font.weight: Font.Bold
            font.bold: true
            font.pointSize: fontSizes.large
        }

        TextArea
        {
            id: body
            visible: typeof model.body !== 'undefined'
            Layout.leftMargin: visible ? space.medium : 0
            Layout.bottomMargin: visible ? space.medium : 0
            Layout.rightMargin: visible ? space.medium : 0
            Layout.topMargin: title.visible ? 0 : space.medium

            Layout.fillHeight: visible
            Layout.fillWidth: visible
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
            Layout.margins: unit
            clip: true
            Layout.topMargin: space.medium
            visible: img.status === Image.Ready

            Image
            {
                id: img
                visible: status === Image.Ready
                asynchronous: true
                anchors.centerIn: parent

                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                height: parent.height
                width: parent.width
                sourceSize.height: height
                sourceSize.width: width
                fillMode: Image.PreserveAspectCrop
                source: "file://"+encodeURIComponent( model.preview ) || ""

                layer.enabled: img.visible
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: img.width
                        height: img.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: img.width
                            height: img.height
                            radius: cardRadius
                            //                    radius: Math.min(width, height)
                        }
                    }
                }
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
