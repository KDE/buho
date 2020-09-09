import QtQuick 2.14
import "../../widgets"
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

import Books 1.0

StackView
{
    id: control

    property alias list : _booksList
    property alias cardsView : cardsView
    property var currentBook : ({})

    readonly property bool editing : depth > 1

    Component
    {
        id: _bookletComponent

        BookletPage
        {
            onExit: control.pop()
        }
    }

    initialItem: Maui.Page
    {
        id: _booksPage

        headBar.visible: !_holder.visible

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: qsTr("Search ") + _booksList.count + " " + qsTr("books")
            onAccepted: _booksModel.filter = text
            onCleared: _booksModel.filter = ""
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
            onClicked: newBook()
        }

        Maui.Holder
        {
            id: _holder
            visible: _booksList.count === 0
            emoji: "qrc:/view-books.svg"
            emojiSize: Maui.Style.iconSizes.huge
            title : qsTr("There are not Books!")
            body: qsTr("You can create new books and organize your notes")
        }

        Maui.AltBrowser
        {
            id: cardsView

            visible: !_holder.visible
            viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

            anchors.fill: parent
            gridView.itemSize: 140
            gridView.itemHeight: gridView.itemSize * 1.2
            gridView.margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

            listView.topMargin: Maui.Style.contentMargins
            listView.spacing: Maui.Style.space.medium

            model: Maui.BaseModel
            {
                id: _booksModel
                sortOrder: Qt.DescendingOrder
                sort: "modified"
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive

                list: Books
                {
                    id: _booksList
                    currentBook: mappedIndex(cardsView.currentIndex)
                }
            }

            listDelegate: Maui.ItemDelegate
            {
                id: _listDelegate
                width: cardsView.width
                height: Maui.Style.rowHeight * 2
                isCurrentItem: ListView.isCurrentItem
                leftPadding: Maui.Style.space.small
                rightPadding: Maui.Style.space.small

                Kirigami.Theme.backgroundColor: Qt.lighter(control.Kirigami.Theme.backgroundColor, 2)

                RowLayout
                {
                    anchors.fill: parent

                    Rectangle
                    {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.margins: Maui.Style.space.small
                        color: model.color
                        radius: Maui.Style.radiusV

                       Label
                       {
                           text: model.title[0].toUpperCase()
                           font.pointSize: Maui.Style.iconSizes.big
                           color: Qt.lighter(parent.color)
                           anchors.centerIn: parent
                       }
                    }

                    Maui.ListItemTemplate
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        rightMargin: Maui.Style.space.small
                        isCurrentItem: _listDelegate.isCurrentItem
                        hovered: _listDelegate.hovered
                        label1.text: model.title
                        //                        labe1.font.bold: true
                        label1.font.weight: Font.Bold
                        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                        Maui.Badge
                        {
                            radius: 4
                            text: model.count
                        }
                    }
                }

                onClicked:
                {
                    cardsView.currentIndex = index
                    control.currentBook = _booksModel.get(cardsView.currentIndex)
                    control.push(_bookletComponent)
                }

            }

            gridDelegate: Maui.ItemDelegate
            {
                id: _delegate

                width: cardsView.gridView.cellWidth
                height: cardsView.gridView.cellHeight
                isCurrentItem: GridView.isCurrentItem

                background: Item {}

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: model.url

                ColumnLayout
                {
                    height: cardsView.gridView.itemHeight
                    width: cardsView.gridView.itemSize -20
                    anchors.centerIn: parent
                    spacing: Maui.Style.space.medium
                    Rectangle
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: model.color
                        radius: Maui.Style.radiusV

                        Label
                        {
                            text: model.title[0].toUpperCase()
                            font.pointSize: Maui.Style.iconSizes.huge
                            color: Qt.lighter(parent.color)
                            anchors.centerIn: parent
                        }
                    }

                    Maui.ListItemTemplate
                    {
                        isCurrentItem: _delegate.isCurrentItem
                        hovered: _delegate.hovered
                        Layout.fillWidth: true
                        label1.text: model.title
                        //                        labe1.font.bold: true
                        label1.font.weight: Font.Bold
                        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                        Maui.Badge
                        {
                            radius: 4
                            text: model.count
                        }
                    }
                }

                onClicked:
                {
                    cardsView.currentIndex = index
                    control.currentBook = _booksModel.get(index)
                    control.push(_bookletComponent)
                }
            }
        }
    }
}







