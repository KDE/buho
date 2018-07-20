import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    id: control
    property string noteColor : color ? color : viewBackgroundColor
    property int cardWidth: visible ? unit * 200 : 0
    property int cardHeight: visible ? unit * 120 : 0
    property int cardRadius: unit * 4

    property bool condition : true

    signal rightClicked();

    visible: condition

    width: cardWidth
    height: cardHeight
    hoverEnabled: !isMobile
    background: Rectangle
    {
        color: "transparent"
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    DropShadow
    {
        anchors.fill: card
        visible: card.visible
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: Qt.darker(noteColor, 1.5)
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
        radius: cardRadius
    }

    ColumnLayout
    {
        height: parent.height * 0.9
        width: parent.width * 0.9
        anchors.centerIn: parent
        spacing: 0
        clip: true

        Label
        {
            id: title
            padding: 0
            visible: title.text.length > 0
            Layout.leftMargin: space.medium
            Layout.topMargin: space.medium
            Layout.rightMargin: space.medium
            Layout.alignment: Qt.AlignLeft

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
            padding: 0
            visible: typeof model.body !== 'undefined'
            Layout.leftMargin: visible ? space.medium : 0
            Layout.bottomMargin: visible ? space.medium : 0
            Layout.rightMargin: visible ? space.medium : 0
            Layout.topMargin: title.visible ? 0 : space.medium
            Layout.alignment: Qt.AlignLeft
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

    function update(item)
    {
        console.log("update link color", item.color)
        model.title = item.title
        model.body = item.body
        model.color = item.color
        model.pin = item.pin ? 1 : 0
        model.fav = item.fav ? 1 : 0
    }
}
