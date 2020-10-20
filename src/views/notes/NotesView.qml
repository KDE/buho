import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui

import org.kde.kirigami 2.7 as Kirigami
import Notes 1.0

import "../../widgets"

StackView
{
    id: control
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias list : notesList
    property alias currentIndex : cardsView.currentIndex

    readonly property bool editing : control.depth > 1

    function setNote(note)
    {
        control.push(_editNoteComponent, {}, StackView.Immediate)
        control.currentItem.editor.body.forceActiveFocus()
    }

    function newNote()
    {
        control.push(_newNoteComponent, {}, StackView.Immediate)
        control.currentItem.editor.body.forceActiveFocus()
    }

    Component
    {
        id: _editNoteComponent
        NewNoteDialog
        {
            note: control.currentNote
            onNoteSaved: control.list.update(note, control.currentIndex)
        }
    }

    Component
    {
        id: _newNoteComponent
        NewNoteDialog
        {
            onNoteSaved: control.list.insert(note)
        }
    }

    initialItem: CardsView
    {
        id: cardsView

        holder.visible: notesList.count < 1
        holder.emoji: "qrc:/view-notes.svg"
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.title :i18n("No notes!")
        holder.body: i18n("Click here to create a new note")
        viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        model: Maui.BaseModel
        {
            id: notesModel
            list: Notes
            {
                id: notesList
            }
            sortOrder: settings.sortOrder
            sort: settings.sortBy
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        Maui.FloatingButton
        {
            z: parent.z + 1
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: height
            height: Maui.Style.toolBarHeight

            icon.name: "list-add"
            icon.color: Kirigami.Theme.highlightedTextColor
            onClicked: newNote()
        }

        headBar.visible: !holder.visible
        //        headBar.leftContent: Maui.ToolActions
        //        {
        //            autoExclusive: true
        //            expanded: isWide
        //            currentIndex : cardsView.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1
        //            display: ToolButton.TextBesideIcon

        //            Action
        //            {
        //                text: i18n("List")
        //                icon.name: "view-list-details"
        //                onTriggered: cardsView.viewType = MauiLab.AltBrowser.ViewType.List
        //            }

        //            Action
        //            {
        //                text: i18n("Cards")
        //                icon.name: "view-list-icons"
        //                onTriggered: cardsView.viewType= MauiLab.AltBrowser.ViewType.Grid
        //            }
        //        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Search ") + notesList.count + " " + i18n("notes")
            onAccepted: notesModel.filter = text
            onCleared: notesModel.filter = ""
        }

        listDelegate: CardDelegate
        {
            width: ListView.view.width
            height: 150

            onClicked:
            {
                currentIndex = index
                currentNote = model
                setNote()
            }

            onRightClicked:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.popup()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.popup()
            }
        }

        gridDelegate: Item
        {
            id: delegate
            width: cardsView.gridView.cellWidth
            height: cardsView.gridView.cellHeight

            CardDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium

                onClicked:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)

                    setNote()
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.popup()
                }
            }
        }

        Connections
        {
            target: cardsView.holder
            function onActionTriggered()
            {
                newNote()
            }
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
                text: i18n("Export")
                onTriggered:
                {
                    _notesMenu.close()
                }
            }

            MenuItem
            {
                icon.name : "edit-copy"
                text: i18n("Copy")
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
                text: i18n("Remove")
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

