import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

ListView
{
    id: control
    clip: true

    property int itemWidth: unit * 200
    property int itemHeight: unit * 200
    signal itemClicked(int index)
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    orientation: ListView.Horizontal
    spacing: space.large
    Maui.Holder
    {
        id: holder
        visible: count < 1
        message: "<h3>No pinned notes!</h3><p>You can pin your notes to see them here</p>"
    }

    model: notesView.cardsView.model
    delegate: CardDelegate
    {
        cardWidth: model.pin == 1 ? itemWidth : 0
        cardHeight:  model.pin == 1 ? itemHeight : 0
        condition: model.pin == 1

        onClicked:
        {
            currentIndex = index
            itemClicked(index)
        }
    }

}
