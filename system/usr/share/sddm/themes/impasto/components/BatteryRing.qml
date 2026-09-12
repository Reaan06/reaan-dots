// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   B A T T E R Y   R I N G                                                │
// │   charge as a ring · read straight out of sysfs                          │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Shapes

import "."

// The lock screen's battery chip, reading /sys/class/power_supply directly
// since the greeter has no UPower. QML cannot glob, so BAT0–BAT2 are tried in
// order; with no battery the chip stays hidden.
//
// Needs QML_XHR_ALLOW_FILE_READ (set in /etc/sddm.conf.d/10-impasto.conf);
// without it every read fails silently.
Item {
    id: root

    property real size: Theme.capsuleHeight

    // The Material battery glyphs are not contiguous, so they are listed.
    readonly property var levelIcons: [
        "󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"
    ]

    property int percent: 0
    property string state: ""
    property bool available: false

    readonly property bool charging: root.state === "Charging"
    readonly property bool full: root.state === "Full"
    readonly property bool low: root.available && !root.charging && !root.full
        && root.percent <= 20

    // Fixed status hues, stepped by level.
    readonly property color tint: {
        if (!root.available)
            return Theme.textMuted
        if (root.charging || root.full)
            return "#32d74b"
        if (root.percent <= 15)
            return Theme.indicatorBad
        if (root.percent <= 35)
            return Theme.indicatorWarn
        return "#32d74b"
    }

    readonly property string glyph: {
        if (!root.available)
            return "󰂑"
        if (root.charging)
            return "󰂄"
        if (root.low)
            return "󰂃"
        const step = Math.max(0, Math.min(10, Math.round(root.percent / 10)))
        return root.levelIcons[step]
    }

    readonly property real thickness: 2.5
    readonly property real ringRadius: (Math.min(width, height) - root.thickness) / 2
    readonly property real fraction: Math.max(0, Math.min(1, root.percent / 100))

    implicitWidth: root.size
    implicitHeight: root.size
    visible: root.available

    // ── SYSFS ───────────────────────────────────────────────────────────────

    property string battery: ""

    function read(name: string, file: string, done: var): void {
        const request = new XMLHttpRequest()
        request.onreadystatechange = function () {
            if (request.readyState !== XMLHttpRequest.DONE)
                return
            done(request.status === 200 ? String(request.responseText).trim() : "")
        }
        request.open("GET", `file:///sys/class/power_supply/${name}/${file}`)
        request.send()
    }

    function refresh(): void {
        if (root.battery === "") {
            for (const name of ["BAT0", "BAT1", "BAT2"]) {
                root.read(name, "capacity", function (value) {
                    if (value === "" || root.battery !== "")
                        return
                    root.battery = name
                    root.percent = parseInt(value, 10)
                    root.available = true
                    root.read(name, "status", v => root.state = v)
                })
            }
            return
        }

        root.read(root.battery, "capacity", function (value) {
            if (value === "")
                return
            root.percent = parseInt(value, 10)
        })
        root.read(root.battery, "status", v => root.state = v)
    }

    Component.onCompleted: root.refresh()

    // Charge changes slowly.
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    // ── RING ────────────────────────────────────────────────────────────────

    Shape {
        anchors.fill: parent
        // The curve renderer antialiases the sweep properly; the default one
        // leaves a visibly stepped edge at this size.
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.thickness
            strokeColor: "#4d4d4d"
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.tint
            fillColor: "transparent"
            // Rounded ends read as a gauge rather than a cut pie slice; at zero
            // they would still paint a dot, hence the guard on the sweep.
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: -90
                sweepAngle: root.fraction <= 0 ? 0 : root.fraction * 360

                Behavior on sweepAngle {
                    NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        font.family: Theme.fontMono
        font.pixelSize: Math.round(root.size * 0.38)
        // White; the ring carries the level.
        color: Theme.indicator
    }
}
