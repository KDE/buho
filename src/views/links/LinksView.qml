import QtQuick 2.9
import "../../widgets"
import org.kde.maui 1.0 as Maui

Maui.Page
{
    id: control

    property alias cardsView : cardsView
    property alias previewer : previewer
    property var currentLink : ({})
    signal linkClicked(var link)
    headBarVisible: !cardsView.holder.visible

    margins: isMobile ? space.big : space.enormus
    headBarExit: false
    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName: cardsView.gridView ? "view-list-icons" : "view-list-details"
            onClicked:
            {
                cardsView.gridView = !cardsView.gridView
                cardsView.refresh()
            }
        },
        Maui.ToolButton
        {
            iconName: "view-sort-ascending"

        },

        Maui.ToolButton
        {
            iconName: "view-sort-descending"

        }
    ]

    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "tag-recents"

        },

        Maui.ToolButton
        {
            iconName: "window-pin"

        },

        Maui.ToolButton
        {
            iconName: "view-calendar-day"

        }
    ]


    Previewer
    {
        id: previewer
    }

    CardsView
    {
        id: cardsView
        anchors.fill: parent
        onItemClicked: linkClicked(cardsView.model.get(index))
        holder.emoji: "qrc:/Astronaut.png"
        holder.isMask: false
        holder.title : "No Links!"
        holder.body: "Click here to save a new link"
        holder.emojiSize: iconSizes.huge
        Connections
        {
            target: cardsView.holder
            onActionTriggered: newLink()
        }
    }

    function populate()
    {
        var data =  owl.getLinks()
        for(var i in data)
        {
            console.log("PREVIEW", data[i].preview)
            append(data[i])
        }

    }

    function append(link)
    {
        cardsView.model.append(link)
    }
}
