// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C A P T U R E   B A R                                                  │
// │   capture options · region, kind and action                              │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "../theme"
import "../services"
import "../components"

// Capture options: the shape, the kind, and where the result goes (or, for a
// recording, whether it includes audio). Drawn in the island's black at the
// bottom of the screen.
Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 52
    radius: height / 2
    color: Theme.island
    border.color: Theme.islandBorder
    border.width: 1

    // The bar takes its own presses; without this, a click on a segment starts
    // a selection underneath it.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => mouse.accepted = true
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: 12

        SegmentedControl {
            anchors.verticalCenter: parent.verticalCenter
            options: [
                { id: "region", label: "Region" },
                { id: "window", label: "Window" },
                { id: "screen", label: "Screen" }
            ]
            current: CaptureService.shape
            onSelected: id => CaptureService.setShape(id)
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: 22
            color: Theme.islandBorder
        }

        SegmentedControl {
            anchors.verticalCenter: parent.verticalCenter
            options: [
                { id: "photo", label: "Photo" },
                { id: "video", label: "Video" }
            ]
            current: CaptureService.kind
            onSelected: id => CaptureService.setKind(id)
        }

        // Third group: where a screenshot goes, or whether a recording captures
        // audio. One slot for both, so the bar keeps its shape.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            visible: CaptureService.kind === "photo" || RecorderService.canAudio
            width: 1
            height: 22
            color: Theme.islandBorder
        }

        SegmentedControl {
            anchors.verticalCenter: parent.verticalCenter
            visible: CaptureService.kind === "photo"
            // Destinations whose tool is missing are hidden rather than
            // disabled.
            options: [
                { id: "file", label: "Save" },
                { id: "clipboard", label: "Copy" }
            ].concat(CaptureService.offers("editor")
                    ? [{ id: "editor", label: "Annotate" }] : [])
             .concat(CaptureService.offers("text")
                    ? [{ id: "text", label: "Text" }] : [])
            current: CaptureService.to
            onSelected: id => CaptureService.to = id
        }

        // System audio (the monitor source), not the microphone. Hidden when
        // there is no monitor source.
        SegmentedControl {
            anchors.verticalCenter: parent.verticalCenter
            visible: CaptureService.kind === "video" && RecorderService.canAudio
            options: [
                { id: "mute", label: "No sound" },
                { id: "sound", label: "Sound" }
            ]
            current: SettingsService.recorderAudio ? "sound" : "mute"
            onSelected: id => SettingsService.set("recorderAudio", id === "sound")
        }
    }
}
