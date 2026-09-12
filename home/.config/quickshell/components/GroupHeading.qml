// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   G R O U P   H E A D I N G                                              │
// │   settings group heading · with optional details                         │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// Section heading on a settings page: a mark, a name and a one-line `note`.
// `hint` is a longer explanation behind the info glyph, toggled by click
// rather than hover so the page does not shift under the pointer.
ColumnLayout {
    id: root

    property string icon: ""
    property string title: ""

    // One line, always shown.
    property string note: ""

    // Longer explanation, behind the info glyph.
    property string hint: ""

    property bool opened: false

    // No top gap for the first heading on a page.
    property bool leading: false

    Layout.fillWidth: true
    Layout.topMargin: root.leading ? 0 : 14
    spacing: 1

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        spacing: 9

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.fontMono
            font.pixelSize: 13
            color: Theme.accent
        }

        Text {
            text: root.title
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4
            color: Theme.text
        }

        Text {
            visible: root.hint !== ""
            text: "󰋼"
            font.family: Theme.fontMono
            font.pixelSize: 11
            color: root.opened ? Theme.accent : Theme.textMuted
            opacity: root.opened || hintMouse.containsMouse ? 1 : 0.6

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

            MouseArea {
                id: hintMouse
                anchors.fill: parent
                anchors.margins: -5
                hoverEnabled: true
                cursorShape: Qt.WhatsThisCursor
                onClicked: root.opened = !root.opened
            }
        }

        Item { Layout.fillWidth: true }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        visible: root.note !== ""
        text: root.note
        wrapMode: Text.WordWrap
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLabel
        color: Theme.textMuted
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.topMargin: root.opened ? 4 : 0
        Layout.rightMargin: 20
        visible: root.opened && root.hint !== ""
        text: root.hint
        wrapMode: Text.WordWrap
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLabel
        color: Theme.textMuted
        opacity: 0.85
    }
}
