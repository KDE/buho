import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

MauiLab.AltBrowser
{
    id: control

    viewType: MauiLab.AltBrowser.ViewType.Grid
    property alias menu : cardMenu
    property int defaultSize : 300

    signal itemClicked(int index)

    gridView.itemSize: Math.min(defaultSize, control.width* 0.4)
    gridView.cellHeight: defaultSize + Maui.Style.space.big
    gridView.topMargin: Maui.Style.contentMargins
    listView.topMargin: Maui.Style.contentMargins
    listView.spacing: Maui.Style.space.big

    CardMenu
    {
        id: cardMenu
    }
}
