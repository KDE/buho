import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.0 as Maui
import org.mauikit.controls 1.1 as MauiLab

MauiLab.AltBrowser
{
    id: control

    viewType: MauiLab.AltBrowser.ViewType.Grid

    signal itemClicked(int index)

    gridView.itemSize: Math.min(300, control.width* 0.4)
    gridView.cellHeight: gridView.itemSize + Maui.Style.rowHeight
}
