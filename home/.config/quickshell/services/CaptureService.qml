// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C A P T U R E   S E R V I C E                                          │
// │   screenshots · capture, crop and save                                   │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "../theme"

// Each output gets its own `capture.py grab` photograph and overlay. The
// chosen output's picture is cropped by `capture.py finish`; other temporary
// pictures are discarded. Nothing is frozen, and menus remain in the capture.
//
// Shape and kind are remembered (`captureShape`, `captureKind`); the
// destination resets to a file every time.
Singleton {
    id: root

    readonly property string script: Quickshell.shellPath("scripts/capture.py")

    // ── TOOLS ───────────────────────────────────────────────────────────────

    // Probed once and filled asynchronously; use `can()`. A missing tool
    // disables its control.
    property var tools: ({})
    property bool ready: false

    readonly property string directory: root.tools.directory ?? ""

    function can(what: string): bool {
        return root.tools[what] === true
    }

    // ── SURFACE ─────────────────────────────────────────────────────────────

    // Photos are keyed by connector name so each overlay can only draw and
    // finish the image captured from its own output.
    property var photos: ({})
    property var outputs: []
    property var received: []
    property int pending: 0
    property string captureError: ""

    property bool active: false
    property bool busy: false
    property int generation: 0

    // This binding is driven by Quickshell's notifiable screens list and the
    // monitor service's refreshed geometry rows. A topology change invalidates
    // a delayed, running, or visible capture without depending on an overlay.
    readonly property string screenTopology: {
        const screens = []
        for (const screen of Quickshell.screens)
            screens.push(`${screen.name}:${screen.width}x${screen.height}`)
        const monitors = []
        for (const monitor of MonitorService.monitors ?? [])
            monitors.push(`${monitor.name}:${monitor.x}:${monitor.y}:`
                           + `${monitor.width}:${monitor.height}:${monitor.disabled}:`
                           + `${monitor.positionValid}`)
        return `${screens.sort().join("|")}#${monitors.sort().join("|")}`
    }
    onScreenTopologyChanged: root.invalidate()

    readonly property Connections monitorEvents: Connections {
        target: Hyprland

        function onRawEvent(event): void {
            switch (event.name) {
            case "configreloaded":
            case "monitoradded":
            case "monitoraddedv2":
            case "monitorremoved":
            case "monitorremovedv2":
                root.monitorLayoutDirty = true
                root.invalidate()
                if (MonitorService.reader.running)
                    root.monitorRefreshQueued = true
                else
                    root.refreshMonitorLayout()
                break
            }
        }
    }

    readonly property Connections monitorRows: Connections {
        target: MonitorService

        function onMonitorsChanged(): void {
            if (!root.monitorRefreshPending || root.monitorRefreshQueued)
                return
            root.monitorRefreshDataReady = true
            root.finishMonitorRefresh()
        }
    }

    readonly property Connections monitorReader: Connections {
        target: MonitorService.reader

        function onExited(): void {
            if (root.monitorRefreshQueued) {
                root.refreshMonitorLayout()
                return
            }
            if (!root.monitorRefreshPending)
                return
            root.monitorRefreshExited = true
            root.finishMonitorRefresh()
        }
    }

    property int grabIndex: 0
    property string grabOutput: ""
    property int grabGeneration: -1
    property string grabText: ""
    property bool grabExited: false
    property bool grabStreamFinished: false
    property bool grabHandled: false
    property bool monitorLayoutDirty: false
    property bool monitorRefreshPending: false
    property bool monitorRefreshQueued: false
    property bool monitorRefreshDataReady: false
    property bool monitorRefreshExited: false
    readonly property bool monitorGeometryReady:
        !root.monitorLayoutDirty && !MonitorService.reader.running

    // Delay a caller closing a panel passes to `open()`, so the panel is gone
    // from the photo. It is the island's close animation, 0 with motion off.
    readonly property int settle: Theme.durationIslandGone

    // ── OPTIONS ─────────────────────────────────────────────────────────────

    readonly property var shapes: ["region", "window", "screen"]
    readonly property var kinds: ["photo", "video"]
    readonly property var destinations: ["file", "clipboard", "editor", "text"]

    readonly property string shape: SettingsService.captureShape
    readonly property string kind: SettingsService.captureKind
    property string to: "file"

    function setShape(id: string): void {
        SettingsService.set("captureShape", id)
    }

    function setKind(id: string): void {
        SettingsService.set("captureKind", id)
    }

    // Destinations whose tool is missing are not offered.
    function offers(id: string): bool {
        if (id === "editor")
            return root.can("editor")
        if (id === "text")
            return root.can("text")
        return true
    }

    // ── OPEN AND CLOSE ──────────────────────────────────────────────────────

    signal opened()

    // A window and a region reach the encoder as the same rectangle, so the
    // shape is passed along with it.
    signal recordRequested(string shape, string geometry)

    function refreshMonitorLayout(): void {
        root.monitorRefreshPending = true
        root.monitorRefreshQueued = false
        root.monitorRefreshDataReady = false
        root.monitorRefreshExited = false
        MonitorService.load()
    }

    function finishMonitorRefresh(): void {
        if (!root.monitorRefreshPending || !root.monitorRefreshDataReady
            || !root.monitorRefreshExited)
            return
        root.monitorRefreshPending = false
        root.monitorLayoutDirty = false
    }

    // Empty `shape`/`kind` keep the last choice.
    function open(shape: string, kind: string, destination: string, after: int): void {
        if (root.active || root.busy || root.shooter.running)
            return
        root.generation += 1
        if (shape !== "")
            root.setShape(shape)
        if (kind !== "")
            root.setKind(kind)
        root.to = destination !== "" && root.offers(destination) ? destination : "file"

        const requested = []
        for (const screen of Quickshell.screens) {
            const output = screen?.name ?? ""
            if (output !== "" && !requested.includes(output))
                requested.push(output)
        }
        if (requested.length === 0) {
            OsdService.requested(root.marks.error, "No screens to capture", -1)
            return
        }

        root.clearPhotos("")
        root.photos = ({})
        root.outputs = requested
        root.received = []
        root.pending = requested.length
        root.grabIndex = 0
        root.captureError = ""
        root.busy = true
        root.launch.interval = after
        root.launch.restart()
    }

    function dropPath(path: string): void {
        if (path !== "")
            Quickshell.execDetached([root.script, "drop", path])
    }

    // Delete every temporary picture except the one being passed to finish.
    function clearPhotos(keepPath: string): void {
        for (const output of Object.keys(root.photos)) {
            const path = root.photos[output]?.path ?? ""
            if (path !== keepPath)
                root.dropPath(path)
        }
        root.photos = ({})
    }

    function grabbed(output: string, generation: int, text: string): void {
        let report
        try {
            report = JSON.parse(text)
        } catch (error) {
            report = null
        }

        if (generation !== root.generation || !root.busy
            || !root.outputs.includes(output) || root.received.includes(output)) {
            root.dropPath(report?.path ?? "")
            return
        }
        root.received = [...root.received, output]

        const path = report?.path ?? ""
        if (!report || report.error || path === "") {
            if (path !== "")
                root.dropPath(path)
            if (root.captureError === "")
                root.captureError = report?.error ?? "Could not capture a screen"
        } else {
            root.photos = Object.assign({}, root.photos, {
                [output]: {
                    path: path,
                    width: Number(report.width) || 0,
                    height: Number(report.height) || 0
                }
            })
        }

        root.pending = Math.max(0, root.pending - 1)
        if (root.pending > 0)
            return

        root.busy = false

        const complete = root.outputs.every(name => !!root.photos[name]?.path)
        if (root.captureError !== "" || !complete) {
            const message = root.captureError !== ""
                ? root.captureError : "Could not capture every screen"
            root.clearPhotos("")
            root.outputs = []
            root.received = []
            root.pending = 0
            root.captureError = ""
            OsdService.requested(root.marks.error, message, -1)
            return
        }

        root.pending = 0
        root.active = true
        root.opened()
    }

    // The singleton owns the worker, so removed overlays cannot strand a
    // pending callback. Its generation token rejects and drops late results.
    function startGrab(): void {
        if (!root.busy || root.launch.running || root.grabber.running
            || root.grabIndex >= root.outputs.length)
            return
        const output = root.outputs[root.grabIndex]
        root.grabIndex += 1
        root.grabOutput = output
        root.grabGeneration = root.generation
        root.grabText = ""
        root.grabExited = false
        root.grabStreamFinished = false
        root.grabHandled = false
        root.grabber.command = [root.script, "grab", output]
        root.grabber.running = true
    }

    function finishGrab(): void {
        if (!root.grabExited || !root.grabStreamFinished || root.grabHandled)
            return
        root.grabHandled = true
        root.grabbed(root.grabOutput, root.grabGeneration, root.grabText)
        root.grabText = ""
        root.startGrab()
    }

    function invalidate(): void {
        if (!root.active && !root.busy)
            return
        root.generation += 1
        root.launch.stop()
        root.active = false
        root.busy = false
        root.clearPhotos("")
        root.outputs = []
        root.received = []
        root.pending = 0
        root.grabIndex = 0
        root.captureError = ""
    }

    // Escape or a click on nothing. Late worker results are dropped by the
    // generation guard rather than being attached to a later capture.
    function cancel(): void {
        root.invalidate()
    }

    // Logical coordinates local to `output`. An empty box means that output's
    // whole screen; video geometry is translated back to compositor space.
    function fire(output: string, x: real, y: real, width: real, height: real,
                  surfaceWidth: real, surfaceHeight: real,
                  screenX: real, screenY: real): void {
        if (!root.active)
            return
        const picture = root.photos[output]
        if (!picture?.path)
            return

        const whole = width <= 0 || height <= 0
        const kind = root.kind
        const destination = root.to

        // Hide every surface before saving or starting a recording.
        root.active = false
        root.clearPhotos(picture.path)
        root.outputs = []
        root.received = []

        if (kind === "video") {
            // RecorderService remains global; only this overlay's still image
            // is discarded and the selected box is sent in compositor space.
            root.dropPath(picture.path)
            root.recordRequested(whole ? "screen" : root.shape,
                                 whole ? "" : root.box(x + screenX, y + screenY,
                                                       width, height))
            return
        }

        const command = [root.script, "finish", picture.path]
        if (!whole) {
            command.push("--geometry", root.cropGeometry(x, y, width, height))
            if (surfaceWidth > 0 && surfaceHeight > 0
                && picture.width > 0 && picture.height > 0) {
                command.push("--logical-size", `${surfaceWidth}x${surfaceHeight}`)
                command.push("--photo-size", `${picture.width}x${picture.height}`)
            }
        }
        command.push("--to", destination)
        root.shooter.command = command
        root.shooter.running = true
    }

    // Preserve fractional selection coordinates until capture.py scales and
    // rounds the screenshot crop in photo pixels.
    function cropGeometry(x: real, y: real, width: real, height: real): string {
        return `${x},${y} ${width}x${height}`
    }

    // The recorder receives compositor (logical) coordinates rounded as before.
    function box(x: real, y: real, width: real, height: real): string {
        return `${Math.round(x)},${Math.round(y)} `
             + `${Math.round(width)}x${Math.round(height)}`
    }

    // ── PROCESSES ───────────────────────────────────────────────────────────

    readonly property Process probe: Process {
        command: [root.script, "tools"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.tools = JSON.parse(text)
                    root.ready = true
                } catch (error) {
                    console.warn("Cannot read what capture.py can do:", error)
                }
            }
        }
    }

    readonly property Timer launch: Timer {
        onTriggered: root.startGrab()
    }

    readonly property Process grabber: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                root.grabText = text
                root.grabStreamFinished = true
                root.finishGrab()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    console.warn("capture:", text.trim())
            }
        }
        onExited: {
            root.grabExited = true
            root.finishGrab()
        }
    }

    readonly property Process shooter: Process {
        stdout: StdioCollector {
            onStreamFinished: root.took(text)
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    console.warn("capture:", text.trim())
            }
        }
    }

    // ── OSD ─────────────────────────────────────────────────────────────────

    readonly property var marks: ({
        file: "󰹑",
        clipboard: "󰹑",
        editor: "󰏫",
        text: "󱄽",
        error: "󰀦"
    })

    function took(text: string): void {
        let report
        try {
            report = JSON.parse(text)
        } catch (error) {
            return
        }
        if (report.cancelled)
            return
        if (report.error) {
            OsdService.requested(root.marks.error, report.error, -1)
            return
        }
        OsdService.requested(root.marks[report.to] ?? root.marks.file,
                             root.said(report), -1)
    }

    function said(report: var): string {
        switch (report.to) {
        case "file":
            // File name only; the directory is always the same.
            return String(report.path ?? "").split("/").pop()
        case "clipboard":
            return report.copied ? "Copied" : "Not copied"
        case "editor":
            return "Opening the editor"
        case "text":
            if (!report.characters)
                return "No text found"
            return report.copied
                ? `${report.characters} characters copied`
                : `${report.characters} characters`
        }
        return ""
    }
}
