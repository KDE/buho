import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    headBar.middleContent: [
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "draw-text"
            text: qsTr("Notes")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "link"
            text: qsTr("Links")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "document-new"
            text: qsTr("Books")
        }
    ]

    footBar.middleContent: Maui.PieButton
    {
        id: addButton
        iconName: "list-add"

        model: ListModel
        {
            ListElement {iconName: "document-new"}
            ListElement {iconName: "link"}
            ListElement {iconName: "draw-text"}
            ListElement {iconName: "link"}
            ListElement {iconName: "details-view"}

        }
    }

    footBar.leftContent: Maui.ToolButton
    {
        iconName: "document-share"
    }

    footBar.rightContent: Maui.ToolButton
    {
        iconName: "archive-remove"
    }

}
