import QtQuick 2.9
import "../../widgets"
import org.kde.mauikit 1.0 as Maui
import "../../utils/owl.js" as O

Maui.Page
{
    id: control

    property alias cardsView : cardsView
    property alias previewer : previewer
    property var currentLink : ({})
    signal linkClicked(var link)
    headBarVisible: !cardsView.holder.visible

    margins: space.big
    headBarExit: false
    headBarTitle : cardsView.count + " links"
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
            iconName: "edit-pin"

        },

        Maui.ToolButton
        {
            iconName: "view-calendar"

        }
    ]

    Previewer
    {
        id: previewer
        onLinkSaved: if(owl.updateLink(link))
                         cardsView.currentItem.update(link)
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

        Connections
        {
            target: cardsView.menu
            onDeleteClicked: if(O.removeLink(cardsView.model.get(cardsView.currentIndex)))
                                 cardsView.model.remove(cardsView.currentIndex)
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
