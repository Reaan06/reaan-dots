import QtQuick

Item {
    id: root

    property color color: "white"

    ChatGPTMark {
        anchors.fill: parent
        color: root.color
    }
}
