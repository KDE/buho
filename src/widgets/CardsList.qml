import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

ListView
{
    id: control
    clip: true

    property int itemWidth: unit * 300
    property int itemHeight: unit * 200
    signal itemClicked(int index)

    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    orientation: ListView.Horizontal
    spacing: 0

    Maui.Holder
    {
        id: holder
        visible: count < 1
        message: "<h3>No pinned notes!</h3><p>You can pin your notes to see them here</p>"
    }

    model: notesView.model
    delegate: Item
    {
        width: model.pin == 1 ? itemWidth : 0
        height:  model.pin == 1 ? itemHeight : 0
        visible: model.pin == 1

        CardDelegate
        {
            cardWidth: parent.width * 0.8
            cardHeight:  parent.height

            anchors.centerIn: parent

            onClicked:
            {
                currentIndex = index
                itemClicked(index)
            }
        }
    }

}
