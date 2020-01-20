import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import "../../widgets"
import QtWebView 1.1

Maui.Dialog
{
    parent: parent
    heightHint: 0.97
    widthHint: 0.97
    maxWidth: 800*Maui.Style.unit
    maxHeight: maxWidth
    page.padding: 0
    property color selectedColor : "transparent"

    signal linkSaved(var link)
    headBar.leftContent: [
        ToolButton
        {
            id: pinButton
            icon.name: "pin"
            checkable: true
            icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            //                onClicked: checked = !checked
        },

        ToolButton
        {
            icon.name: "document-save"
        },

        ToolButton
        {
            icon.name: "document-launch"
            onClicked: Qt.openUrlExternally(_webView.url)
        }
    ]

    headBar.rightContent: ColorsBar
    {
        id: colorBar
        onColorPicked: selectedColor = color
    }

    footBar.leftContent: [

        ToolButton
        {
            id: favButton
            icon.name: "love"
            checkable: true
            icon.color: checked ? "#ff007f" : Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "document-share"
            onClicked: isAndroid ? Maui.Android.shareLink(_webView.url) :
                                   shareDialog.show(_webView.url)
        },

        ToolButton
        {
            icon.name: "document-export"
        },

        ToolButton
        {
            icon.name: "entry-delete"
        }
    ]

    onAccepted:
    {
        packLink()
        close()
    }

    onRejected: close()

    acceptText: qsTr("Save")
    rejectText:  qsTr("Discard")
//    colorScheme.backgroundColor: selectedColor

    ColumnLayout
    {
        anchors.fill: parent
        WebView
        {
            id: _webView
            Layout.fillWidth: true
            Layout.fillHeight: true

            onVisibleChanged:
            {
                if(!visible) _webView.url = "about:blank"
            }
        }

        Maui.TagsBar
        {
            id: tagBar
            Layout.fillWidth: true
            allowEditMode: true
            list.abstract: true
            list.key: "links"
            onTagsEdited: list.updateToAbstract(tags)
            onTagRemovedClicked: list.removeFromAbstract(index)
        }
    }


    function show(link)
    {
        console.log("STATE:" , link.fav)
        _webView.url = link.url
        tagBar.list.lot = link.url
        pinButton.checked = link.pin == 1
        favButton.checked = link.fav == 1
        selectedColor = link.color
        open()
    }

    function packLink()
    {
        console.log(favButton.checked)
        linkSaved({
                      title: _webView.title,
                      url: _webView.url,
                      color: selectedColor,
                      tag: tagBar.getTags(),
                      pin: pinButton.checked ? 1 : 0,
                      fav: favButton.checked ? 1 : 0,
                      updated: new Date()
                  })
    }
}
