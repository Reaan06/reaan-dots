// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C A P S U L E                                                          │
// │   black capsule surface                                                  │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "."

// The surface for every control: pure black with a 1 px outline, like the
// shell's capsules.
Rectangle {
    id: root

    property bool hovered: false

    implicitHeight: Theme.capsuleHeight
    radius: Math.min(height / 2, Theme.radiusLarge + 4)

    // Hover changes only the (opaque) fill. Animating the border towards a
    // translucent colour passes through a brighter grey and flashes.
    color: root.hovered ? Theme.islandSurfaceHover : Theme.island
    border.width: 1
    border.color: Theme.islandBorder

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
}
