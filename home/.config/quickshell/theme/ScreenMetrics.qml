// Per-screen metrics scale safe local visuals: spacing, workspace marks and
// shadows. Outer bar/grid tokens stay fixed until gaps and child internals are
// per-screen aware.
import QtQuick

QtObject {
    id: root

    property var screen: null

    readonly property real widthFactor: root.screen?.width > 0
        ? root.screen.width / 1920 : 1
    readonly property real heightFactor: root.screen?.height > 0
        ? root.screen.height / 1080 : 1
    readonly property real factor: Math.max(0.88, Math.min(1.15,
        Math.min(root.widthFactor, root.heightFactor)))

    function px(value: real): int {
        return Math.max(1, Math.round(value * root.factor))
    }
}
