import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

ItemDelegate
{
    id: control
    property string noteColor : model.color ? model.color : Kirigami.Theme.backgroundColor
    implicitWidth: Maui.Style.unit * 200
    implicitHeight: Maui.Style.unit * 120
    property int cardRadius: Maui.Style.radiusV

    property bool condition : true

    signal rightClicked();

    visible: condition

    hoverEnabled: !Kirigami.Settings.isMobile
    background: Rectangle
    {
        border.color: Qt.darker(color, 1.2)
        color:  noteColor
        radius: cardRadius
        opacity: hovered ? 0.8 : 1
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!Kirigami.Settings.isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    Maui.Holder
    {
        visible: !title.visible
        title: qsTr("Empty")
        body: qsTr("Edit this note")
        emoji: "qrc:/view-notes.svg"
        emojiSize: Maui.Style.iconSizes.large
        isMask: true
    }

    Kirigami.Icon
    {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Maui.Style.space.medium
        source: "love"
        color: model.color ? Qt.darker(model.color, 3) : Kirigami.Theme.textColor
        height: Maui.Style.iconSizes.small
        width: height
        visible: model.favorite == 1
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
            Layout.leftMargin: Maui.Style.space.medium
            Layout.topMargin: Maui.Style.space.medium
            Layout.rightMargin: Maui.Style.space.medium
            Layout.alignment: Qt.AlignLeft

            Layout.fillWidth: true
            text: Qt.formatDateTime(new Date(model.modified), "h:mm d MMM yyyy")
            color: model.color ? Qt.darker(model.color) : Kirigami.Theme.textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.WrapAnywhere
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.small
        }

        Label
        {
            id: title
            padding: 0
            visible: title.text.length > 0
            Layout.leftMargin: Maui.Style.space.medium
            Layout.bottomMargin: Maui.Style.space.medium
            Layout.rightMargin: Maui.Style.space.medium
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.preferredHeight: model.preview ? parent.height * 0.4 : implicitHeight

            Layout.fillWidth: true
            Layout.fillHeight: true
            text: model.title
            color: model.color ? Qt.darker(model.color, 3) : Kirigami.Theme.textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.WrapAnywhere
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            clip: true
        }

        Loader
        {
            id: bodyLoader
            Layout.leftMargin: Maui.Style.space.medium
            Layout.bottomMargin: Maui.Style.space.medium
            Layout.rightMargin: Maui.Style.space.medium
            Layout.topMargin: title.visible ? 0 : Maui.Style.space.medium
            Layout.alignment: Qt.AlignLeft
            Layout.fillHeight: true
            Layout.fillWidth: true
            sourceComponent:  model.content ? bodyComponent : null
        }

        Loader
        {
            id: imgLoader
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Maui.Style.unit
            Layout.alignment: Qt.AlignCenter
            clip: true
            Layout.topMargin: Maui.Style.space.medium
            sourceComponent:  model.preview ? imgComponent : null
        }
    }

    Component
    {
        id: bodyComponent

        TextArea
        {
            id: body
            padding: 0
            visible: model.content && body.text.length > 0
            enabled: false
            text: model.content ? model.content : ""
            color: model.color ? Qt.darker(model.color, 3) : Kirigami.Theme.textColor
            wrapMode: TextEdit.WrapAnywhere

            textFormat : TextEdit.AutoText
            font.pointSize: Maui.Style.fontSizes.big
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
            source: model.preview ? model.preview  : ''

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
