// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E T T I N G S   H E R O                                              │
// │   settings page heading                                                  │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// Settings page header: mark, name and one line, left-aligned, a step larger
// than the group headings.
ColumnLayout {
    id: root

    property string icon: ""
    property string title: ""
    property string blurb: ""

    spacing: 3

    RowLayout {
        Layout.leftMargin: 4
        spacing: 10

        Text {
            text: root.icon
            font.family: Theme.fontMono
            font.pixelSize: 17
            color: Theme.accent
        }

        Text {
            text: root.title
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.DemiBold
            color: Theme.text
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        visible: root.blurb !== ""
        text: root.blurb
        wrapMode: Text.WordWrap
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.textMuted
    }
}
