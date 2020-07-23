import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.NewDialog
{
    id: control

    signal bookSaved(string title)
    entryField: true

    title: qsTr("New Book")
    message: qsTr("Give a title to your new book. Your new book can contain many notes grouped together")


    textEntry.placeholderText:  qsTr("My Book...")

    acceptButton.text: qsTr("Create")
    rejectButton.text: qsTr("Cancel")

    onFinished:
    {
        control.bookSaved(text)
        close()
    }
}
