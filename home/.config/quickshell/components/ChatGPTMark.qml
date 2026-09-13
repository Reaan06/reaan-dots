import QtQuick

Item {
    id: root

    property color color: "white"

    // ChatGPT spark: six rounded petals around a central dot.
    Repeater {
        model: 6

        Rectangle {
            required property int index
            anchors.centerIn: parent
            width: Math.max(3, parent.width * 0.30)
            height: parent.height * 0.58
            radius: width / 2
            color: root.color
            rotation: index * 60
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.max(3, parent.width * 0.22)
        height: width
        radius: width / 2
        color: root.color
    }
}
