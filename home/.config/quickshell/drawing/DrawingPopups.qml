import QtQuick
import "../theme"

Item {
    id: root

    property bool showSizePopup: false
    property bool showColorPopup: false
    property string currentTool: "pen"
    property int currentToolSize: 4
    property color currentColor: "#f4f1ed"
    property color panelBg: Qt.rgba(0.12, 0.12, 0.16, 0.96)
    property color panelBorder: Qt.rgba(0.8, 0.8, 0.85, 0.14)
    property color accentColor: Theme.accent || "#0a84ff"
    property color textColor: Theme.text || "#ffffff"
    property string iconFamily: "Font Awesome 7 Free, Font Awesome 6 Free, Iosevka Nerd Font"

    signal sizeChanged(real size)
    signal colorSelected(color col)

    Rectangle {
        id: sizePopup
        visible: root.showSizePopup
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 240
        height: 52
        radius: 12
        color: root.panelBg
        border.color: root.panelBorder
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentTool === "eraser" ? "\uF12D"
                    : (root.currentTool === "brush" ? "\uF1FC"
                    : (root.currentTool === "marker" ? "\uF576" : "\uF040"))
                font.family: root.iconFamily
                font.pixelSize: 15
                color: root.accentColor
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 140
                height: 6
                radius: 3
                color: "#302f3b"

                Rectangle {
                    height: parent.height
                    width: (root.currentToolSize / 64) * parent.width
                    radius: 3
                    color: root.accentColor
                }

                Rectangle {
                    x: Math.max(0, Math.min(parent.width - 14, (root.currentToolSize / 64) * parent.width - 7))
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: "#ffffff"
                    border.color: root.accentColor
                    border.width: 2
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    preventStealing: true
                    onPressed: mouse => root.sizeChanged((mouse.x / width) * 64)
                    onPositionChanged: mouse => {
                        if (pressed) root.sizeChanged((mouse.x / width) * 64)
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentToolSize + "px"
                color: root.textColor
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    Rectangle {
        id: colorPopup
        visible: root.showColorPopup
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: 252
        height: 80
        radius: 12
        color: root.panelBg
        border.color: root.panelBorder
        border.width: 1

        Grid {
            anchors.centerIn: parent
            columns: 6
            spacing: 8
            Repeater {
                model: [
                    "#ffffff", "#a6adc8", "#e68b83", "#f38ba8", "#fab387", "#f9e2af",
                    "#a6e3a1", "#94e2d5", "#74c7ec", "#89b4fa", "#cba6f7", "#313244"
                ]
                delegate: Rectangle {
                    required property string modelData
                    width: 28; height: 28; radius: 14
                    color: modelData
                    border.width: Qt.colorEqual(root.currentColor, modelData) ? 3 : 1
                    border.color: Qt.colorEqual(root.currentColor, modelData) ? "#ffffff" : "#45475a"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.colorSelected(modelData)
                    }
                }
            }
        }
    }
}
