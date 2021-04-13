import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.buho 1.0

import "../../widgets"

StackView
{
    id: control
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias list : notesList
    property alias currentIndex : cardsView.currentIndex

    readonly property Flickable flickable : currentItem.flickable

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
            onNoteSaved:
            {
                console.log("updating note <<" , note)
                control.list.update(note, control.currentIndex)
            }
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

    Maui.Dialog
    {
        id: _removeNotesDialog

        property var notes

        title: i18n("Remove notes")
        message: i18n("Are you sure you want to delete the selected notes?")

        template.iconSource: "view-notes"

        page.margins: Maui.Style.space.big

        onAccepted:
        {
            console.log (notes)
        }

        onRejected: close()

    }

    initialItem: CardsView
    {
        id: cardsView

        floatingFooter: true

        holder.visible: notesList.count < 1
        holder.emoji: "qrc:/view-notes.svg"
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.title :i18n("No notes!")
        holder.body: i18n("Click here to create a new note")
        enableLassoSelection: true

        viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        property string typingQuery

         Maui.Chip
         {
             z: cardsView.z + 99999
             Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
             visible: _typingTimer.running
             label.text: cardsView.typingQuery
             anchors.left: parent.left
             anchors.bottom: parent.bottom
             showCloseButton: false
             anchors.margins: Maui.Style.space.medium
         }

         Timer
         {
             id: _typingTimer
             interval: 250
             onTriggered:
             {
                 const index = notesList.indexOfName(cardsView.typingQuery)
                 if(index > -1)
                 {
                     control.currentIndex = index
                 }

                 cardsView.typingQuery = ""
             }
         }

        Connections
        {
            target: cardsView.currentView
            ignoreUnknownSignals: true

            function onItemsSelected(indexes)
            {
                console.log(indexes)
                for(var index of indexes)
                    select(notesModel.get(index))
            }

            function onKeyPress(event)
            {
                const index = cardsView.currentIndex
                const item = notesModel.get(index)

                var pat = /^([a-zA-Z0-9 _-]+)$/
                if(event.count === 1 && pat.test(event.text))
                {
                    cardsView.typingQuery += event.text
                    _typingTimer.restart()
                }

                if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                {
                    cardsView.currentView.itemsSelected([index])
                }

                if(event.key === Qt.Key_Return)
                {
                    currentNote = item
                    setNote()
                }
            }
        }

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

        headBar.visible: !holder.visible

        headBar.rightContent: ToolButton
        {
            icon.name: "list-add"
            onClicked: newNote()
        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Search ") + notesList.count + " " + i18n("notes")
            onAccepted: notesModel.filter = text
            onCleared: notesModel.filter = ""
        }

        footer: Maui.SelectionBar
        {
            id: _selectionbar
            visible: count > 0 && !swipeView.currentItem.editing
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            padding: Maui.Style.space.big
            maxListHeight: swipeView.height - Maui.Style.space.medium

            onExitClicked:
            {
                cardsView.selectionMode = false
                clear()
            }

            listDelegate: Maui.ItemDelegate
            {
                height: Maui.Style.rowHeight * 2
                width: ListView.view.width

                background: Rectangle
                {
                    color: model.color ? model.color : "transparent"
                    radius:Maui.Style.radiusV
                }

                Maui.ListItemTemplate
                {
                    id: _template
                    anchors.fill: parent
                    label1.text: model.title
                    iconSizeHint: Maui.Style.iconSizes.small
                    iconSource: "view-pim-notes"
                    checkable: true
                    checked: true
                    onToggled: _selectionbar.removeAtIndex(index)
                }
            }

            Action
            {
                text: i18n("Favorite")
                icon.name: "love"
                onTriggered:
                {
                    for(var item of _selectionbar.items)
                        notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), notesList.indexOfNote(item.path))

                    _selectionbar.clear()
                }
            }

            Action
            {
                text: i18n("Share")
                icon.name: "document-share"
            }

            Action
            {
                text: i18n("Export")
                icon.name: "document-export"
            }

            Action
            {
                text: i18n("Delete")
                Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                icon.name: "edit-delete"

                onTriggered:
                {
                    _removeNotesDialog.notes = _selectionbar.uris
                    _removeNotesDialog.open()
                }
            }
        }

        listDelegate: CardDelegate
        {
            id: _listDelegate
            width: ListView.view.width
            height: 150
            checkable: cardsView.selectionMode
            checked: _selectionbar.contains(model.path)
            isCurrentItem: ListView.isCurrentItem

            onClicked:
            {
                currentIndex = index

                if(cardsView.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                {
                    cardsView.currentView.itemsSelected([index])
                }else if(Maui.Handy.singleClick)
                {
                    currentNote = notesModel.get(index)
                    setNote()
                }
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick && !cardsView.selectionMode)
                {
                    currentNote = notesModel.get(index)
                    setNote()
                }
            }

            onRightClicked:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.open()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.open()
            }

            onToggled:
            {
                currentIndex = index
                select(notesModel.get(index))
            }

            Connections
            {
                target: _selectionbar
                ignoreUnknownSignals: true

                function onUriRemoved(uri)
                {
                    if(uri === model.url)
                    {
                        _listDelegate.checked = false
                    }
                }

                function onUriAdded(uri)
                {
                    if(uri === model.url)
                    {
                        _listDelegate.checked = true
                    }
                }

                function onCleared()
                {
                    _listDelegate.checked = false
                }
            }
        }

        gridDelegate: Item
        {
            id: delegate
            width: cardsView.gridView.cellWidth
            height: cardsView.gridView.cellHeight

            property bool isCurrentItem: GridView.isCurrentItem

            CardDelegate
            {
                id: _gridDelegate
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                checkable: cardsView.selectionMode
                checked: _selectionbar.contains(model.path)
                isCurrentItem: parent.isCurrentItem

                onClicked:
                {
                    currentIndex = index

                    if(cardsView.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                    {
                        cardsView.currentView.itemsSelected([index])
                    }else if(Maui.Handy.singleClick)
                    {
                        currentNote = notesModel.get(index)
                        setNote()
                    }
                }

                onDoubleClicked:
                {
                    control.currentIndex = index
                    if(!Maui.Handy.singleClick && !cardsView.selectionMode)
                    {
                        currentNote = notesModel.get(index)
                        setNote()
                    }
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.open()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.open()
                }

                onToggled:
                {
                    currentIndex = index
                    select(notesModel.get(index))
                }
            }

            Connections
            {
                target: _selectionbar
                ignoreUnknownSignals: true

                function onUriRemoved(uri)
                {
                    if(uri === model.url)
                    {
                        _gridDelegate.checked = false
                    }
                }

                function onUriAdded(uri)
                {
                    if(uri === model.url)
                    {
                        _gridDelegate.checked = true
                    }
                }

                function onCleared()
                {
                    _gridDelegate.checked = false
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

        Maui.ContextualMenu
        {
            id: _notesMenu

            property bool isFav: currentNote.favorite == 1

            MenuItem
            {
                text: i18n("Select")
                icon.name: "item-select"
                onTriggered:
                {
                    if(Maui.Handy.isTouch)
                    {
                        cardsView.selectionMode = true
                    }

                    cardsView.currentView.itemsSelected([cardsView.currentIndex])
                }
            }

            MenuItem
            {
                icon.name: "love"
                text: _notesMenu.isFav? i18n("UnFav") : i18n("Fav")
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


    function select(item)
    {
        if(_selectionbar.contains(item.path))
        {
            _selectionbar.removeAtUri(item.path)
        }else
        {
            _selectionbar.append(item.path, item)

        }
    }
}

