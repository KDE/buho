import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    id: control
    property string noteColor : model.color ? model.color : viewBackgroundColor
    property int cardWidth: visible ? unit * 200 : 0
    property int cardHeight: visible ? unit * 120 : 0
    property int cardRadius: radiusV

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

    Rectangle
    {
        id: card
        z: -999
        anchors.centerIn: control
        anchors.fill: control
        border.color: Qt.darker(noteColor, 1.2)
        color: noteColor
        radius: cardRadius

        Loader
        {
            id: imgLoader
            anchors.fill: parent
            anchors.margins: space.small
            clip: true
            sourceComponent:  typeof model.preview !== 'undefined' ? imgComponent : undefined
        }
    }

    Rectangle
    {
        anchors.fill: parent
        color: hovered? "#333" :  "transparent"
        z: 999
        opacity: 0.2
        radius: cardRadius
    }

    Item
    {
        visible: title.text.length > 0
        height: layout.implicitHeight + space.big
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: unit

        ColumnLayout
        {
            id: layout
            anchors.fill: parent
            anchors.margins: space.small
            spacing: 0
            Label
            {
                id: date
                Layout.fillWidth: true
                Layout.fillHeight: true

                padding: 0
                visible: date.text.length > 0
                text: Qt.formatDateTime(new Date(model.updated), "d MMM h:mm")
                color: model.color ? Qt.darker(model.color) : textColor
                elide: Qt.ElideRight
                wrapMode: TextEdit.WrapAnywhere
                font.weight: Font.Bold
                font.bold: true
                font.pointSize: fontSizes.small
            }

            Label
            {
                id: title
                padding: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: model.title ? model.title : ""
                color: model.color ? Qt.darker(model.color, 3) : textColor
                elide: Qt.ElideRight
                wrapMode: TextEdit.WrapAnywhere
                font.weight: Font.Bold
                font.bold: true
                font.pointSize: fontSizes.large
                clip: true
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color: noteColor
            z: -1
        }
    }


    Component
    {
        id: bodyComponent

        TextArea
        {
            id: body
            padding: 0
            visible: typeof model.body !== 'undefined'

            enabled: false
            text: model.body ? model.body : ""
            color: model.color ? Qt.darker(model.color, 3) : textColor
            wrapMode: TextEdit.WrapAnywhere

            textFormat: TextEdit.RichText
            font.pointSize: fontSizes.big

            background: Rectangle
            {
                color: "transparent"
            }
        }
    }

    Component
    {
        id: imgComponent

        Image
        {
            id: img

            visible: status === Image.Ready
            asynchronous: true

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            height: parent.height
            width: parent.width
            sourceSize.height: height
            sourceSize.width: width
            fillMode: Image.PreserveAspectCrop
            source: model.preview ? "file://"+encodeURIComponent( model.preview ) : ''

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

    function update(item)
    {
        console.log("update link color", item.color, item.tag)
        model.title = item.title
        model.body = item.body
        model.color = item.color
        model.pin = item.pin ? 1 : 0
        model.fav = item.fav ? 1 : 0
        model.updated = item.updated
        model.tag = item.tag.join(",")
    }
}
