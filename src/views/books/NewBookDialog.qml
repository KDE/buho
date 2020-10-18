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

    title: i18n("New Book")
    message: i18n("Give a title to your new book. Your new book can contain many notes grouped together")


    textEntry.placeholderText:  i18n("My Book...")

    acceptButton.text: i18n("Create")
    rejectButton.text: i18n("Cancel")

    onFinished:
    {
        control.bookSaved(text)
        close()
    }
}
