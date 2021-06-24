import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.ItemDelegate
{
    id: control

    implicitWidth: Maui.Style.unit * 200
    implicitHeight: Maui.Style.unit * 120

    property string noteColor : model.color ? model.color : "transparent"
    property int cardRadius: Maui.Style.radiusV

    property bool checkable: false
    property bool checked : false

    signal toggled(bool state)

    draggable: true

    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": control.filterSelectedItems(model.path)
                       } : {}


    Rectangle
    {
        anchors.fill: parent
        color: Qt.darker(Kirigami.Theme.textColor)
        opacity: 0.2
        visible: control.checkable || control.checked
        radius: control.cardRadius
    }

    background: Rectangle
    {
        Kirigami.Theme.inherit: false
        border.color: control.isCurrentItem || control.checked || hovered ? Kirigami.Theme.highlightColor : "transparent"
        color:  control.noteColor !== "transparent" ? control.noteColor : Qt.lighter(Kirigami.Theme.backgroundColor)
        radius: control.cardRadius
        border.width: control.isCurrentItem || control.checked || hovered ? 2 : 1
    }

    Maui.Holder
    {
        visible: !title.visible
        title: i18n("Empty")
        body: i18n("Edit this note")
        emoji: "qrc:/view-notes.svg"
        emojiSize: Maui.Style.iconSizes.large
        Kirigami.Theme.textColor: date.color
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

    Maui.Badge
    {
        id: _emblem

        visible: control.checkable || control.checked
        size: Maui.Style.iconSizes.medium
        anchors.margins: Maui.Style.space.medium
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: control.checked ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.5)

        border.color: Kirigami.Theme.textColor

        onClicked:
        {
            control.checked = !control.checked
            control.toggled(control.checked)
        }

        Kirigami.Icon
        {
            visible: opacity > 0
            color: Kirigami.Theme.highlightedTextColor
            anchors.centerIn: parent
            height: control.checked ? Math.round(parent.height * 0.9) : 0
            width: height
            opacity: control.checked ? 1 : 0
            isMask: true

            source: "qrc:/assets/checkmark.svg"

            Behavior on opacity
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big
        spacing: Maui.Style.space.small
        clip: true

        Label
        {
            id: date
            padding: 0
            visible: date.text.length > 0
            Layout.leftMargin: Maui.Style.space.medium
            Layout.topMargin: Maui.Style.space.medium
            Layout.rightMargin: Maui.Style.space.medium
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            Layout.fillWidth: true
            text: Qt.formatDateTime(new Date(model.modified), "h:mm d MMM yyyy")
            color: model.color ? Qt.darker(model.color) : Kirigami.Theme.textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.WrapAnywhere
            font.family: settings.font.family
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
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.preferredHeight: model.preview ? parent.height * 0.4 : implicitHeight

            Layout.fillWidth: true

            text: model.title
            color: model.color ? Qt.darker(model.color, 3) : Kirigami.Theme.textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.WrapAnywhere
            font.family: settings.font.family
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            clip: true
        }

        Loader
        {
            id: bodyLoader
            asynchronous: true
            Layout.leftMargin: Maui.Style.space.medium
            Layout.bottomMargin: Maui.Style.space.medium
            Layout.rightMargin: Maui.Style.space.medium
            Layout.topMargin: title.visible ? 0 : Maui.Style.space.medium
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            sourceComponent:  model.content ? bodyComponent : null
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
            font.family: settings.font
            textFormat : TextEdit.AutoText
            font.pointSize: Maui.Style.fontSizes.big
            background: Rectangle
            {
                color: "transparent"
            }
        }
    }
 }
