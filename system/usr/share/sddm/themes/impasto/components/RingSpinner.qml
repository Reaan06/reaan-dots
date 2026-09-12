// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   R I N G   S P I N N E R                                                │
// │   loading spinner                                                        │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Shapes

import "."

// Shown while PAM is authenticating.
Item {
    id: root

    property color fillColor: Theme.accent
    property real thickness: 2
    property bool running: false

    implicitWidth: 18
    implicitHeight: 18

    Shape {
        id: arc

        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.thickness) / 2
                radiusY: (root.height - root.thickness) / 2
                startAngle: -90
                sweepAngle: 100
            }
        }

        RotationAnimator {
            target: arc
            running: root.running
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
        }
    }
}
