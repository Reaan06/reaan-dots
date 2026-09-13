import QtQuick

import "../theme"

// A compact quota gauge with its value and reset-window label inside the ring.
Item {
    id: root

    property real usedPercent: 0
    property bool available: false
    property string label: ""
    property color trackColor: Theme.indicatorDim
    property color fillColor: Theme.indicator
    property color textColor: Theme.text
    property color labelColor: Theme.textMuted
    property int ringThickness: 3

    implicitWidth: 52
    implicitHeight: 52

    RingIndicator {
        anchors.fill: parent
        progress: root.available ? root.usedPercent / 100 : 0
        thickness: root.ringThickness
        trackColor: root.trackColor
        fillColor: root.available ? root.fillColor : root.trackColor

        Column {
            anchors.centerIn: parent
            spacing: -1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.available ? `${Math.round(root.usedPercent)}%` : "—"
                font.family: Theme.fontMono
                font.pixelSize: Math.max(10, Math.round(root.width * 0.22))
                font.weight: Font.DemiBold
                color: root.textColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.label
                visible: root.label !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Math.max(8, Math.round(root.width * 0.16))
                color: root.labelColor
            }
        }
    }
}
