import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import Notes 1.0
import Qt.labs.platform 1.0 as Labs

import "../../widgets"

Maui.Page
{
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias model : notesModel
    property alias list : notesList
    property alias currentIndex : cardsView.currentIndex

    signal noteClicked(var note)
    flickable: cardsView

    padding: Maui.Style.space.big

    headBar.visible: !cardsView.holder.visible

    headBar.leftContent: [
        ToolButton
        {
            icon.name:  cardsView.gridView ? "view-list-details" : "view-list-icons"
            onClicked:
            {
                cardsView.gridView = !cardsView.gridView
            }
        }
    ]

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Search ") +cardsView.count + " " + qsTr("notes")
        onAccepted: notesModel.filter = text
        onCleared: notesModel.filter = ""
    }

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "view-sort"
            onClicked: sortMenu.open();

            Menu
            {
                id: sortMenu

                Labs.MenuItemGroup
                {
                    id: orderGroup
                }

                Labs.MenuItemGroup
                {
                    id: sortGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Ascedent")
                    checkable: true
                    checked: notesList.order === Notes.ASC
                    onTriggered: notesList.order = Notes.ASC
                    group: sortGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Descendent")
                    checkable: true
                    checked: notesList.order === Notes.DESC
                    onTriggered: notesList.order = Notes.DESC
                    group: sortGroup
                }

                MenuSeparator{}

               Labs.MenuItem
                {
                    text: qsTr("Title")
                    checkable: true
                    checked: notesList.sortBy === Notes.TITLE
                    onTriggered: notesList.sortBy = Notes.TITLE
                    group: orderGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Color")
                    checkable: true
                    checked: notesList.sortBy === Notes.COLOR
                    onTriggered: notesList.sortBy = Notes.COLOR
                    group: orderGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                    checked: notesList.sortBy === Notes.ADDDATE
                    onTriggered: notesList.sortBy = Notes.ADDDATE
                    group: orderGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Updated")
                    checkable: true
                    checked: notesList.sortBy === Notes.Modified
                    onTriggered: notesList.sortBy = Notes.Modified
                    group: orderGroup
                }

                Labs.MenuItem
                {
                    text: qsTr("Favorite")
                    checkable: true
                    checked: notesList.sortBy === Notes.FAVORITE
                    onTriggered: notesList.sortBy = Notes.FAVORITE
                    group: orderGroup
                }
            }
        },
        ToolButton
        {
            id: favButton
            icon.name: "love"
            checkable: true
            icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        }
    ]

    Notes
    {
        id: notesList
    }

    Maui.BaseModel
    {
        id: notesModel
        list: notesList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Rectangle
        {
            visible: favButton.checked
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            height: cardsView.itemHeight
            color: Kirigami.Theme.backgroundColor

            Maui.Holder
            {
                id: holder
                visible: favedList.count == 0
                emoji: "qrc:/edit-pin.svg"
                emojiSize: Maui.Style.iconSizes.big
                isMask: true
                title : qsTr("No favorites!")
                body: qsTr("No matched favorites notes. You can fav your notes to access them quickly")
                z: 999
            }

            CardsList
            {
                id: favedList
                height: parent.height *0.9
                width: parent.width * 0.9
                anchors.centerIn: parent
                itemHeight: 150
                itemWidth: itemHeight * 1.5
                onItemClicked: noteClicked(cardsView.model.get(index))
            }
        }


        CardsView
        {
            id: cardsView
            Layout.fillHeight: true
            Layout.fillWidth: true
            width: parent.width
            holder.emoji: "qrc:/view-notes.svg"
            holder.emojiSize: Maui.Style.iconSizes.huge
            holder.title :qsTr("No notes!")
            holder.body: qsTr("Click here to create a new note")

            model: notesModel
            delegate: CardDelegate
            {
                id: delegate
                width: Math.min(cardsView.cellWidth, cardsView.itemWidth) - Kirigami.Units.largeSpacing * 2
                height: cardsView.itemHeight
                anchors.left: parent.left
                anchors.leftMargin: cardsView.width <= cardsView.itemWidth ? 0 : (index % 2 === 0 ? Math.max(0, cardsView.cellWidth - cardsView.itemWidth) :
                                                                                                    cardsView.cellWidth)

                onClicked:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    noteClicked(currentNote)
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    _notesMenu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    _notesMenu.popup()
                }
            }

            Connections
            {
                target: cardsView.holder
                onActionTriggered: newNote()
            }

            Menu
            {
                id: _notesMenu
                width: colorBar.implicitWidth + Maui.Style.space.medium

                property bool isFav: currentNote.favorite == 1

                MenuItem
                {
                    icon.name: "love"
                    text: qsTr(_notesMenu.isFav? "UnFav" : "Fav")
                    onTriggered:
                    {
                        notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), cardsView.currentIndex)
                        _notesMenu.close()
                    }
                }

                MenuItem
                {
                    icon.name: "document-export"
                    text: qsTr("Export")
                    onTriggered:
                    {
                        _notesMenu.close()
                    }
                }

                MenuItem
                {
                    icon.name : "edit-copy"
                    text: qsTr("Copy")
                    onTriggered:
                    {
                        Maui.Handy.copyToClipboard({'text': currentNote.content})
                        _notesMenu.close()
                    }
                }

                MenuSeparator { }

                MenuItem
                {
                    icon.name: "edit-delete"
                    text: qsTr("Remove")
                    Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                    onTriggered:
                    {
                        notesList.remove(cardsView.currentIndex)
                        _notesMenu.close()
                    }
                }

                MenuSeparator { }

                MenuItem
                {
                    width: parent.width
                    height: Maui.Style.rowHeight

                    ColorsBar
                    {
                        id: colorBar
                        anchors.centerIn: parent
                        onColorPicked:
                        {
                            notesList.update(({"color": color}), cardsView.currentIndex)
                            _notesMenu.close()
                        }
                    }
                }
            }
        }
    }
}
