import QtQuick 2.9
import "../../widgets"
import org.kde.maui 1.0 as Maui

Maui.Page
{
    headBarVisible: false
    CardsView
    {
        id: cardsView
        anchors.fill: parent
    }

    function populate()
    {
        var data =  owl.getNotes()
        for(var i in data)
            cardsView.model.append(data[i])
    }
}
