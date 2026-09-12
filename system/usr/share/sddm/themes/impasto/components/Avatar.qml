// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   A V A T A R                                                            │
// │   a face, or the letters that stand in for one                           │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Effects

import "."

// The shell's Avatar without Quickshell: the picture is masked by a disc,
// since `clip` is rectangular and ClippingRectangle is not available. Without
// a picture, which is the common case, it shows initials.
Item {
    id: root

    property string source: ""
    property string initials: "?"
    property color ring: Theme.islandBorder

    implicitWidth: 86
    implicitHeight: 86

    readonly property bool hasPicture: root.source !== ""
        && picture.status === Image.Ready

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.islandSurface
        border.color: root.ring
        border.width: 2

        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
    }

    Image {
        id: picture

        anchors.fill: parent
        anchors.margins: 2
        source: root.source
        visible: false
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: Math.round(root.width * 2)
        sourceSize.height: Math.round(root.height * 2)
    }

    Rectangle {
        id: disc

        anchors.fill: picture
        radius: width / 2
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: picture
        source: picture
        maskEnabled: true
        maskSource: disc
        visible: root.hasPicture
    }

    Text {
        anchors.centerIn: parent
        visible: !root.hasPicture
        text: root.initials
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(root.height * 0.36)
        font.weight: Font.Light
        color: Theme.text
    }
}
