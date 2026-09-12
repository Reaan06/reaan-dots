// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E T T I N G   F I E L D                                              │
// │   a preference that is a piece of text                                   │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// A setting row with a text field. The placeholder shows the system default
// that applies while the field is empty.
Rectangle {
    id: root

    property string label: ""

    // One line; longer text belongs in the group heading's `hint`.
    property string note: ""

    property string placeholder: ""
    property string value: ""

    signal edited(string value)

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + 26
    radius: Theme.radiusMedium
    color: Theme.islandSurface
    border.color: Theme.islandBorder
    border.width: 1

    ColumnLayout {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 4

        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
            color: Theme.text
        }

        Text {
            Layout.fillWidth: true
            visible: root.note !== ""
            text: root.note
            wrapMode: Text.WordWrap
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLabel
            color: Theme.textMuted
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 6
            implicitHeight: 30
            radius: Theme.radiusSmall
            color: Theme.island
            border.color: input.activeFocus ? Theme.accent : Theme.islandBorder
            border.width: 1

            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

            TextInput {
                id: input

                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                text: root.value
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.text
                selectByMouse: true
                selectionColor: Theme.accent
                selectedTextColor: Theme.accentText
                clip: true

                onTextEdited: root.edited(input.text)
                Keys.onEscapePressed: { input.text = ""; root.edited("") }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: input.text === ""
                    text: root.placeholder
                    font: input.font
                    color: Theme.textMuted
                }
            }
        }
    }
}
