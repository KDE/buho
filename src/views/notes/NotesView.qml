import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import "../../widgets"
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import "../../utils/owl.js" as O

import Notes 1.0
import Owl 1.0

Maui.Page
{
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias model : notesModel

    signal noteClicked(var note)

    margins: 0

    headBarExit : false
    headBarVisible: !cardsView.holder.visible
    headBarTitle : cardsView.count + " notes"

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName:  cardsView.gridView ? "view-list-icons" : "view-list-details"
            onClicked:
            {
                cardsView.gridView = !cardsView.gridView
            }
        },
        Maui.ToolButton
        {
            iconName: "view-sort"
            onClicked: sortMenu.open();

            Menu
            {
                 id: sortMenu
                MenuItem
                {
                    text: qsTr("Title")
                    onTriggered: notesModel.sortBy(KEY.TITLE, "ASC")
                }

                MenuItem
                {
                    text: qsTr("Color")
                    onTriggered: notesModel.sortBy(KEY.COLOR, "ASC")
                }

                MenuItem
                {
                    text: qsTr("Add date")
                    onTriggered: notesModel.sortBy(KEY.ADD_DATE, "DESC")
                }

                MenuItem
                {
                    text: qsTr("Updated")
                    onTriggered: notesModel.sortBy(KEY.UPDATED, "DESC")
                }
                MenuItem
                {
                    text: qsTr("Fav")
                    onTriggered: notesModel.sortBy(KEY.FAV, "DESC")
                }
            }
        }
    ]

    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "tag-recents"

        },
        Maui.ToolButton
        {
            id: pinButton
            iconName: "edit-pin"
            checkable: true
            iconColor: checked ? highlightColor : textColor

        },

        Maui.ToolButton
        {
            iconName: "view-calendar"

        }
    ]

    NotesModel
    {
        id: notesModel
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        CardsList
        {
            id: pinnedList
            visible: pinButton.checked
            Layout.margins: isMobile ? space.big : space.enormous
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            height: cardsView.itemHeight
            itemHeight: cardsView.itemHeight * 0.9
            itemWidth: itemHeight
            onItemClicked: noteClicked(cardsView.model.get(index))

        }

        Kirigami.Separator
        {
            visible: pinnedList.visible
            Layout.fillWidth: true
            height: unit
        }

        CardsView
        {
            id: cardsView
            Layout.fillHeight: true
            Layout.fillWidth: true
            width: parent.width
            Layout.margins: space.big
            onItemClicked: noteClicked(notesModel.get(index))
            holder.emoji: "qrc:/Type.png"
            holder.emojiSize: iconSizes.huge
            holder.isMask: false
            holder.title : "No notes!"
            holder.body: "Click here to create a new note"

            model: notesModel
            Connections
            {
                target: cardsView.holder
                onActionTriggered: newNote()
            }

            Connections
            {
                target: cardsView.menu
                onDeleteClicked: if(O.removeNote(cardsView.model.get(cardsView.currentIndex)))
                                     cardsView.model.remove(cardsView.currentIndex)
            }
        }
    }
}
