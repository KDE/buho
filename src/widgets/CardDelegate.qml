import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.ItemDelegate
{
    id: control

    implicitWidth: Maui.Style.unit * 200
    implicitHeight: Maui.Style.unit * 120

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
    readonly property color m_color : Qt.tint(Qt.lighter(control.Kirigami.Theme.textColor), Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))

    color: control.isCurrentItem || control.hovered || control.containsPress ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : Qt.rgba(m_color.r, m_color.g, m_color.b, 0.4)
    border.color: control.isCurrentItem || control.checked || hovered ? Kirigami.Theme.highlightColor : "transparent"
    radius: control.cardRadius
}

Maui.Holder
{
    anchors.fill: parent
    visible: !body.visible && !title.visible
    title: i18n("Empty")
    body: i18n("Edit this note")
}

Kirigami.Icon
{
    anchors.right: parent.right
    anchors.bottom: parent.bottom
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
    anchors.margins: Maui.Style.space.medium
    anchors.leftMargin: _tagColor.width + Maui.Style.space.medium
    spacing: Maui.Style.space.medium
    clip: true

    Label
    {
        id: title
        padding: 0
        visible: title.text.length > 0

        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.preferredHeight: model.preview ? parent.height * 0.4 : implicitHeight

        Layout.fillWidth: true

        text: model.title
        color: Kirigami.Theme.textColor
        elide: Qt.ElideRight
        wrapMode: TextEdit.WrapAnywhere
        font.family: settings.font.family
        font.weight: Font.Bold
        font.bold: true
        font.pointSize: Maui.Style.fontSizes.large
        clip: true
    }

    Text
    {
        id: body
        Layout.fillHeight: true
        Layout.fillWidth: true

        padding: 0
        visible: model.content && text.length > 0
        text: model.content ? model.content : ""
        color: Kirigami.Theme.textColor
        wrapMode: TextEdit.WrapAnywhere
        font.family: settings.font.family
        textFormat : TextEdit.PlainText
        font.pointSize: Maui.Style.fontSizes.default

    }
}

Kirigami.ShadowedRectangle
{
    id: _tagColor
    visible:  model.color && model.color.length
    color: visible ? model.color : "transparent"

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: visible ? 8 : 0

    corners
    {
        topLeftRadius: control.cardRadius
        topRightRadius: 0
        bottomLeftRadius: control.cardRadius
        bottomRightRadius: 0
    }
}

}
