import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

import "src/widgets"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    headBar.middleContent: Row
    {
        spacing: space.medium
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "draw-text"
            text: qsTr("Notes")
        }
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "link"
            text: qsTr("Links")
        }
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "document-new"
            text: qsTr("Books")
        }
    }

    footBar.middleContent: Maui.PieButton
    {
        id: addButton
        iconName: "list-add"

        model: ListModel
        {
            ListElement {iconName: "document-new"; mid: "page"}
            ListElement {iconName: "link"; mid: "link"}
            ListElement {iconName: "draw-text"; mid: "note"}
            ListElement {iconName: "view-list-details"; mid: "todo"}
        }

        onItemClicked:
        {
            if(item.mid === "note")
                newNoteDialog.open()
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

    /***** COMPONENTS *****/

    NewNoteDialog
    {
        id: newNoteDialog
    }


}
