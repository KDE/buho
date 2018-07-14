import QtQuick 2.9
import "../../widgets"
import org.kde.maui 1.0 as Maui

Maui.Page
{
    property alias cardsView : cardsView
    property var currentNote : ({})
    signal noteClicked(var note)
    margins: isMobile ? space.big : space.enormus

    headBarVisible: false
    CardsView
    {
        id: cardsView
        anchors.fill: parent
        onItemClicked: noteClicked(cardsView.model.get(index))
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
