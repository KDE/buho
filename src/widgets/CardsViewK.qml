import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.mauikit 1.0 as Maui

Kirigami.CardsGridView
{
    id: cardViewRoot
    property bool gridView : true

    readonly property  int defaultSize : unit * 200
    property int itemWidth : !gridView ?  width :
                                         unit * 400
    property int itemHeight: unit * 120
    property int itemSpacing:  space.huge

    signal itemClicked(int index)
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    maximumColumnWidth: itemWidth

    Maui.Holder
    {
        id: holder
        visible: count < 1
        z: 999
    }

    CardMenu
    {
        id: cardMenu
    }


    model: ListModel
    {
        id: cardsModel
    }

     CardDelegate
    {
        id: delegate
        cardWidth:  itemWidth
        cardHeight: itemWidth

        onClicked:
        {
            currentIndex = index
            itemClicked(index)
        }

        onRightClicked:
        {
            currentIndex = index
            cardMenu.popup()
        }

        onPressAndHold:
        {
            currentIndex = index
            cardMenu.popup()
        }
    }
}
