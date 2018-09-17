/*
*   Copyright (C) 2017 by Marco Martin <mart@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#ifndef MNEMONICATTACHED_H
#define MNEMONICATTACHED_H

#include <QtQml>
#include <QObject>
#include <QQuickWindow>

class QQuickItem;

/**
 * This Attached property is used to calculate automated keyboard sequences
 * to trigger actions based upon their text: if an "&" mnemonic is
 * used (ie "&Ok"), the system will attempt to assign the desired letter giving
 * it priority, otherwise a letter among the ones in the label will be used if
 * possible and not conflicting.
 * Different kinds of controls will have different priorities in assigning the
 * shortcut: for instance the "Ok/Cancel" buttons in a dialog will have priority
 * over fields of a FormLayout.
 * @see ControlType
 *
 * Usually the developer shouldn't use this directly as base components
 * already use this, but only when implementing a custom graphical Control.
 * @since 2.3
 */
class MnemonicAttached : public QObject
{
    Q_OBJECT
    /**
     * The label of the control we want to compute a mnemonic for, instance
     * "Label:" or "&Ok"
     */
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)

    /**
     * The user-visible final label, which will have the shortcut letter underlined,
     * such as "&lt;u&gt;O&lt;/u&gt;k"
     */
    Q_PROPERTY(QString richTextLabel READ richTextLabel NOTIFY richTextLabelChanged)

    /**
     * The label with an "&" mnemonic in the place which will have the shortcut
     * assigned, regardless the & wasassigned by the user or automatically generated.
     */
    Q_PROPERTY(QString mnemonicLabel READ mnemonicLabel NOTIFY mnemonicLabelChanged)

    /**
     * Only if true this mnemonic will be considered for the global assignment
     * default: true
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

    /**
     * the type of control this mnemonic is attached: different types of controls have different importance and priority for shortcut assignment.
     * @see ControlType
     */
    Q_PROPERTY(MnemonicAttached::ControlType controlType READ controlType WRITE setControlType NOTIFY controlTypeChanged)

    /**
     * The final key sequence assigned, if any: it will be Alt+alphanumeric char
     */
    Q_PROPERTY(QKeySequence sequence READ sequence NOTIFY sequenceChanged)

public:
    enum ControlType {
        ActionElement, /** pushbuttons, checkboxes etc */
        DialogButton, /** buttons for dialogs */
        MenuItem, /** Menu items */
        FormLabel, /** Buddy label in a FormLayout*/
        SecondaryControl /** Other controls that are considered not much important and low priority for shortcuts */
    };
    Q_ENUM(ControlType)

    explicit MnemonicAttached(QObject *parent = 0);
    ~MnemonicAttached();

    void setLabel(const QString &text);
    QString label() const;

    QString richTextLabel() const;
    QString mnemonicLabel() const;

    void setEnabled(bool enabled);
    bool enabled() const;

    void setControlType(MnemonicAttached::ControlType controlType);
    ControlType controlType() const;

    QKeySequence sequence();

    //QML attached property
    static MnemonicAttached *qmlAttachedProperties(QObject *object);

protected:
    bool eventFilter(QObject *watched, QEvent *e);
    void updateSequence();

Q_SIGNALS:
    void labelChanged();
    void enabledChanged();
    void sequenceChanged();
    void richTextLabelChanged();
    void mnemonicLabelChanged();
    void controlTypeChanged();

private:
    void calculateWeights();

    //TODO: to have support for DIALOG_BUTTON_EXTRA_WEIGHT etc, a type enum should be exported
    enum {
        // Additional weight for first character in string
        FIRST_CHARACTER_EXTRA_WEIGHT = 50,
        // Additional weight for the beginning of a word
        WORD_BEGINNING_EXTRA_WEIGHT = 50,
        // Additional weight for a 'wanted' accelerator ie string with '&'
        WANTED_ACCEL_EXTRA_WEIGHT = 150,
        // Default weight for an 'action' widget (ie, pushbuttons)
        ACTION_ELEMENT_WEIGHT = 50,
        // Additional weight for the dialog buttons (large, we basically never want these reassigned)
        DIALOG_BUTTON_EXTRA_WEIGHT = 300,
        // Weight for FormLayout labels (low)
        FORM_LABEL_WEIGHT = 20,
        // Weight for Secondary controls which are considered less important (low)
        SECONDARY_CONTROL_WEIGHT = 10,
        // Default weight for menu items
        MENU_ITEM_WEIGHT = 250
    };

    //order word letters by weight
    int m_weight = 0;
    int m_baseWeight = 0;
    ControlType m_controlType = SecondaryControl;
    QMap<int, QChar> m_weights;

    QString m_label;
    QString m_actualRichTextLabel;
    QString m_richTextLabel;
    QString m_mnemonicLabel;
    bool m_enabled = true;

    QPointer<QQuickWindow> m_window;

    //global mapping of mnemonics
    //TODO: map by QWindow
    static QHash<QKeySequence, MnemonicAttached *> s_sequenceToObject;
    static QHash<MnemonicAttached *, QKeySequence> s_objectToSequence;
};

QML_DECLARE_TYPEINFO(MnemonicAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // MnemonicATTACHED_H
