import QtQuick 2.9
import "../../widgets"
import org.kde.maui 1.0 as Maui

Maui.Page
{
    id: control

    property alias cardsView : cardsView

    headBarVisible: false
    margins: isMobile ? space.big : space.enormus


    CardsView
    {
        id: cardsView
        anchors.fill: parent
//        onItemClicked: linkClicked(cardsView.model.get(index))
        holder.message: "<h3>No Books!</h3><p>You can create new notes<br>links and books</p>"

    }

}
