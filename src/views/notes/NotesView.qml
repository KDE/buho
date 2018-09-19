import QtQuick 2.9
import QtQuick.Layouts 1.3
import "../../widgets"
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import "../../utils/owl.js" as O


Maui.Page
{
    property alias cardsView : cardsView
    property var currentNote : ({})
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
                cardsView.refresh()
            }
        },
        Maui.ToolButton
        {
            iconName: "view-sort"

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
            onItemClicked: noteClicked(cardsView.model.get(index))
            holder.emoji: "qrc:/Type.png"
            holder.emojiSize: iconSizes.huge
            holder.isMask: false
            holder.title : "No notes!"
            holder.body: "Click here to create a new note"

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

    function populate()
    {
        var data =  owl.getNotes()
        for(var i in data)
            append(data[i])

    }

    function append(note)
    {
        cardsView.model.append(note)
    }
}
