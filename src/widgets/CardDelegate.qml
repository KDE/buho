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
    }

    Rectangle
    {
        anchors.fill: parent
        color: hovered? "#333" :  "transparent"
        z: 999
        opacity: 0.2
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
            id: date
            padding: 0
            visible: date.text.length > 0
            Layout.leftMargin: space.medium
            Layout.topMargin: space.medium
            Layout.rightMargin: space.medium
            Layout.alignment: Qt.AlignLeft

            Layout.fillWidth: true
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
            visible: title.text.length > 0
            Layout.leftMargin: space.medium
            Layout.bottomMargin: space.medium
            Layout.rightMargin: space.medium
            Layout.alignment: Qt.AlignLeft

            Layout.fillWidth: true
            Layout.fillHeight: true
            text: model.title ? model.title : ""
            color: model.color ? Qt.darker(model.color, 3) : textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.WrapAnywhere
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


        Loader
        {
            id: imgLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: unit
            Layout.alignment: Qt.AlignCenter
            clip: true
            Layout.topMargin: space.medium
            sourceComponent:  typeof model.preview !== 'undefined' ? imgComponent : undefined
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
        console.log("update link color", item.color)
        model.title = item.title
        model.body = item.body
        model.color = item.color
        model.pin = item.pin ? 1 : 0
        model.fav = item.fav ? 1 : 0
        model.updated = item.updated
    }
}
