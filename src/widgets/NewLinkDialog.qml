import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtWebView 1.1

Maui.Dialog
{
    id: control
    parent: parent

    signal linkSaved(var link)
    property bool previewReady : false

    heightHint: 0.95
    widthHint: 0.95
    maxHeight: previewReady ? 1000 : contentLayout.implicitHeight
    maxWidth: Maui.Style.unit *700

    modal: true
    padding: isAndroid ? 1 : undefined
    page.padding: 0

    headBar.visible: previewReady
    footBar.visible: previewReady

    headBar.leftContent: [

        TextField
        {
            id: title
            visible: previewReady
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            height: 24
            placeholderText: qsTr("Title")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            text: _webView.title

            background: Rectangle
            {
                color: "transparent"
            }
        }
    ]

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
            onClicked: isAndroid ? Maui.Android.shareText(link.text) :
                                   shareDialog.show(link.text)
        },

        ToolButton
        {
            icon.name: "document-export"
        }
    ]

    acceptText: qsTr("Save")
    rejectText:  qsTr("Discard")

    onAccepted: packLink()

    onRejected:  close()

    ColumnLayout
    {
        id: contentLayout
        Layout.fillHeight: true
        Layout.fillWidth: true

        TextField
        {
            id: link
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            height: Maui.Style.rowHeight
            verticalAlignment: Qt.AlignVCenter
            placeholderText: qsTr("URL")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            Layout.alignment: Qt.AlignCenter
            text: _webView.url
            background: Rectangle
            {
                color: "transparent"
            }

            onAccepted:
            {
                _webView.url = link.text
                control.previewReady = true
            }

        }

        WebView
        {
            id: _webView
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: control.previewReady
        }

        Maui.TagsBar
        {
            id: tagBar
            position: ToolBar.Footer
            visible: control.previewReady
            Layout.fillWidth: visible
            allowEditMode: true
            list.abstract: true
            list.key: "links"
            list.lot: _webView.url
            onTagsEdited: list.updateToAbstract(tags)
            onTagRemovedClicked: list.removeFromAbstract(index)
        }
    }

    onClosed:
    {
        control.previewReady = false
        _webView.stop()
        link.clear()
        tagBar.clear()
    }

    function fill(link)
    {
        tagBar.list.lot= link.url
        _webView.url = link.url
        favButton.checked = link.favorite == 1

        if(link.url)
            control.previewReady = true
        open()
    }

    function packLink()
    {
        const imgUrl = linksView.list.previewsCachePath() +Math.floor(Math.random() * 100) + ".jpeg";
        _webView.grabToImage(function (result)
        {
            console.log("save to", imgUrl)
            result.saveToFile(imgUrl)
            var data = ({
                            url : _webView.url,
                            title: title.text,
                            preview: "file://"+imgUrl,
                            tag: tagBar.list.tags.join(","),
                            favorite: favButton.checked ? 1 : 0
                        })
            linkSaved(data)
            close()
        }, Qt.size(_webView.width -48,Math.min( _webView.height - 48, _webView.width * 1.2)));

    }
}
