import QtQuick 2.9
import "../../widgets"
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control

    property alias cardsView : cardsView

    headBar.visible: false
    margins: isMobile ? space.big : space.enormous


    CardsView
    {
        id: cardsView
        anchors.fill: parent
//        onItemClicked: linkClicked(cardsView.model.get(index))
        holder.emoji: "qrc:/E-reading.png"
        holder.isMask: false
        holder.title : "No Books!"
        holder.body: "Click here to save a new link"
        holder.emojiSize: iconSizes.huge
    }

}
