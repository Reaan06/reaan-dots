// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   L I N K   R O W                                                        │
// │   a row linking to another settings page                                 │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// A row pointing at a setting that lives on another page, for settings
// shared by two subjects (module data, kept applications). `reading`
// summarises what is there.
Rectangle {
    id: root

    property string label: ""
    property string reading: ""

    signal followed()

    Layout.fillWidth: true
    implicitHeight: Math.max(42, body.implicitHeight + 16)
    radius: Theme.radiusMedium
    color: linkMouse.containsMouse ? Theme.islandSurfaceHover : Theme.islandSurface
    border.color: Theme.islandBorder
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

    RowLayout {
        id: body

        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                visible: root.reading !== ""
                text: root.reading
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLabel
                color: Theme.textMuted
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "󰅂"
            font.family: Theme.fontMono
            font.pixelSize: 13
            color: linkMouse.containsMouse ? Theme.accent : Theme.textMuted

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }
    }

    MouseArea {
        id: linkMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.followed()
    }
}
