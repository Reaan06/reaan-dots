import QtQuick
import "../../theme"

Row {
    id: root

    property real zoom: 1.0
    property color panelBg: Qt.rgba(0.08, 0.08, 0.10, 0.88)
    property color panelBorder: Qt.rgba(0.8, 0.8, 0.85, 0.14)
    property color textColor: Theme.text || "#ffffff"
    property string iconFamily: "Font Awesome 7 Free, Font Awesome 6 Free, Iosevka Nerd Font"

    signal zoomIn()
    signal zoomOut()
    signal zoomReset()
    signal saveClicked()
    signal copyClicked()
    signal closeClicked()

    spacing: 8

    Rectangle {
        height: 34
        width: zoomRow.width + 12
        radius: 9
        color: root.panelBg
        border.color: root.panelBorder
        border.width: 1

        Row {
            id: zoomRow
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                width: 26; height: 26; radius: 6
                color: zoomOutHover.containsMouse ? "#2f2d3a" : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "−"
                    color: root.textColor
                    font.pixelSize: 15
                }
                MouseArea {
                    id: zoomOutHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomOut()
                }
            }

            Rectangle {
                width: 44; height: 26; radius: 6
                color: zoomResetHover.containsMouse ? "#2f2d3a" : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: Math.round(root.zoom * 100) + "%"
                    color: root.textColor
                    font.pixelSize: 11
                    font.bold: true
                }
                MouseArea {
                    id: zoomResetHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomReset()
                }
            }

            Rectangle {
                width: 26; height: 26; radius: 6
                color: zoomInHover.containsMouse ? "#2f2d3a" : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: root.textColor
                    font.pixelSize: 15
                }
                MouseArea {
                    id: zoomInHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomIn()
                }
            }
        }
    }

    Rectangle {
        width: 34; height: 34; radius: 9
        color: saveHover.containsMouse ? "#2f2d3a" : root.panelBg
        border.color: root.panelBorder
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: "\uF019"
            color: root.textColor
            font.family: root.iconFamily
            font.pixelSize: 13
        }
        MouseArea {
            id: saveHover; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.saveClicked()
        }
    }

    Rectangle {
        width: 34; height: 34; radius: 9
        color: copyHover.containsMouse ? "#2f2d3a" : root.panelBg
        border.color: root.panelBorder
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: "\uF0C5"
            color: root.textColor
            font.family: root.iconFamily
            font.pixelSize: 13
        }
        MouseArea {
            id: copyHover; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.copyClicked()
        }
    }

    Rectangle {
        width: 34; height: 34; radius: 9
        color: closeHover.containsMouse ? "#3d2b2f" : root.panelBg
        border.color: root.panelBorder
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: "×"
            color: closeHover.containsMouse ? "#ff8a80" : root.textColor
            font.pixelSize: 19
        }
        MouseArea {
            id: closeHover; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeClicked()
        }
    }
}
