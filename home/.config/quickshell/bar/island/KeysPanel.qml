// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   K E Y S   P A N E L                                                    │
// │   keybinding cheat sheet                                                 │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../services"

// A read-only sheet of key bindings: groups in columns, the action on the left
// and the keys as caps on the right. Rebinding happens in the settings window.
//
// Built from `ShortcutService.sheet` (the compositor's bind list, grouped).
// `sheetColumns` also sizes the island, so the columns are laid out at their
// final size from the first frame.
Item {
    id: root

    signal closed()

    // Reloaded on open, so rebinds made since startup show up.
    Component.onCompleted: HyprlandService.loadBinds()

    // A key drawn as a keycap: the settings page's, one step smaller so a row
    // of four fits beside its action.
    component Cap: Rectangle {
        property string label: ""

        implicitWidth: Math.max(22, capText.implicitWidth + 12)
        implicitHeight: 20
        radius: Theme.radiusSmall - 3
        color: Theme.islandSurface
        border.color: Theme.islandBorder
        border.width: 1

        Text {
            id: capText
            anchors.centerIn: parent
            text: parent.label
            // An arrow is a glyph from the icon font, which only the mono
            // face carries; everything else is a word or a letter.
            readonly property bool glyph: parent.label.codePointAt(0) >= 0xE000
            font.family: capText.glyph ? Theme.fontMono : Theme.fontFamily
            font.pixelSize: capText.glyph ? Theme.fontSizeRegular : Theme.fontSizeLabel
            font.weight: Font.DemiBold
            color: Theme.text
        }
    }

    Row {
        anchors.fill: parent
        spacing: ShortcutService.sheetGutter

        Repeater {
            model: ShortcutService.sheetColumns

            Column {
                id: column

                required property var modelData

                width: ShortcutService.sheetColumnWidth

                Repeater {
                    model: column.modelData

                    Column {
                        id: group

                        required property var modelData

                        width: column.width

                        Item {
                            width: group.width
                            height: ShortcutService.sheetHeadingHeight

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                text: group.modelData.name.toUpperCase()
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLabel
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.8
                                color: Theme.accent
                            }
                        }

                        Repeater {
                            model: group.modelData.rows

                            Rectangle {
                                id: row

                                required property var modelData

                                width: group.width
                                height: ShortcutService.sheetRowHeight
                                radius: Theme.radiusSmall
                                color: rowHover.hovered ? Theme.islandSurface : "transparent"

                                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                                HoverHandler { id: rowHover }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 4
                                    spacing: 12

                                    Text {
                                        Layout.fillWidth: true
                                        text: row.modelData.action
                                        elide: Text.ElideRight
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeRegular
                                        color: Theme.text
                                    }

                                    Row {
                                        spacing: 3

                                        Repeater {
                                            model: row.modelData.caps

                                            Cap {
                                                required property string modelData
                                                label: modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
