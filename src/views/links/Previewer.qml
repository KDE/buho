import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import "../../widgets"

Maui.Dialog
{
    parent: parent
    heightHint: 0.97
    widthHint: 0.97
    maxWidth: 800*unit
    maxHeight: maxWidth
    page.padding: 0
    property color selectedColor : "transparent"
    property alias webView: webViewer.item

    signal linkSaved(var link)
    headBar.leftContent: [
        ToolButton
        {
            id: pinButton
            icon.name: "pin"
            checkable: true
            icon.color: checked ? highlightColor : textColor
            //                onClicked: checked = !checked
        },

        ToolButton
        {
            icon.name: "document-save"
        },

        ToolButton
        {
            icon.name: "document-launch"
            onClicked: Maui.FM.openUrl(webView.url)
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
            icon.color: checked ? "#ff007f" : textColor
        },

        ToolButton
        {
            icon.name: "document-share"
            onClicked: isAndroid ? Maui.Android.shareLink(webView.url) :
                                   shareDialog.show(webView.url)
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

        //            Item
        //            {
        //                Layout.fillWidth: true
        //                height: rowHeightAlt

        //                Label
        //                {
        //                    clip: true
        //                    text: webView.title
        //                    width: parent.width
        //                    height: parent.height
        //                    horizontalAlignment: Qt.AlignHCenter
        //                    verticalAlignment: Qt.AlignVCenter
        //                    font.bold: true
        //                    font.pointSize: fontSizes.big
        //                    font.weight: Font.Bold
        //                    elide: Label.ElideRight
        //                }
        //            }

        Loader
        {
            id: webViewer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
            source: isAndroid ? "qrc:/src/views/links/WebViewAndroid.qml" :
                                "qrc:/src/views/links/WebViewLinux.qml"

            onVisibleChanged:
            {
                if(!visible) webView.url = "about:blank"
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
        webView.url = link.link
        tagBar.list.lot = link.link
        pinButton.checked = link.pin == 1
        favButton.checked = link.fav == 1
        selectedColor = link.color
        open()
    }

    function packLink()
    {
        console.log(favButton.checked)
        linkSaved({
                      title: webView.title,
                      link: webView.url,
                      color: selectedColor,
                      tag: tagBar.getTags(),
                      pin: pinButton.checked ? 1 : 0,
                      fav: favButton.checked ? 1 : 0,
                      updated: new Date()
                  })
    }
}
