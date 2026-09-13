// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C O D E X   S E R V I C E                                            │
// │   account quota from the Codex app-server                       │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Codex account quota for the primary five-hour block and secondary week,
// read through the official Codex app-server protocol.
//
// Runs only while subscribed; refreshes are bounded by the helper process.
Singleton {
    id: root

    // Two-minute resolution is plenty for account quota changes.
    readonly property int pollInterval: 120000

    property int watchers: 0
    property bool available: false
    readonly property bool authenticated: AuthService.chatgptAuthenticated

    // Query once on construction: the bar only builds the module once
    // `available` is true, so nothing would subscribe otherwise.
    Component.onCompleted: root.refresh()

    property string plan: ""
    property real primaryUsedPercent: 0
    property bool secondaryAvailable: false
    property real secondaryUsedPercent: 0
    property real primaryResetAt: 0
    property real secondaryResetAt: 0
    property int primaryWindowDurationMins: 0
    property int secondaryWindowDurationMins: 0

    function windowLabel(minutes: int): string {
        if (minutes <= 0)
            return ""
        if (minutes % (7 * 24 * 60) === 0)
            return `${minutes / (7 * 24 * 60)}w`
        if (minutes % (24 * 60) === 0)
            return `${minutes / (24 * 60)}d`
        if (minutes % 60 === 0)
            return `${minutes / 60}h`
        return `${minutes}m`
    }

    readonly property string primaryWindowLabel: root.windowLabel(root.primaryWindowDurationMins)
    readonly property string secondaryWindowLabel: root.windowLabel(root.secondaryWindowDurationMins)

    function resetNote(timestamp: real, windowAvailable: bool): string {
        if (!root.available || !windowAvailable || timestamp <= 0)
            return ""
        return `resets ${new Date(timestamp * 1000).toLocaleString()}`
    }

    readonly property string primaryResetNote: root.resetNote(root.primaryResetAt, true)
    readonly property string secondaryResetNote: root.resetNote(root.secondaryResetAt, root.secondaryAvailable)
    readonly property real gauge: root.available
        ? Math.max(0, Math.min(1, root.primaryUsedPercent / 100))
        : 0

    function subscribe(): void {
        root.watchers += 1
        root.refresh()
    }

    function release(): void {
        root.watchers = Math.max(0, root.watchers - 1)
    }

    function refresh(): void {
        root.query.running = true
    }

    readonly property Timer poller: Timer {
        interval: root.pollInterval
        repeat: true
        running: root.watchers > 0
        onTriggered: root.refresh()
    }

    readonly property Process query: Process {
        command: [Quickshell.shellPath("scripts/codex_usage.py")]
        stdout: StdioCollector {
            onStreamFinished: {
                let report = null
                try {
                    report = JSON.parse(text)
                } catch (error) {
                    console.warn("Cannot parse the Codex usage report:", error)
                    return
                }
                if (report.available !== true) {
                    root.available = false
                    return
                }
                root.available = true
                root.plan = report.plan || ""
                root.primaryUsedPercent = report.primaryUsedPercent || 0
                root.secondaryAvailable = report.secondaryAvailable === true
                root.secondaryUsedPercent = report.secondaryUsedPercent || 0
                root.primaryResetAt = report.primaryResetAt || 0
                root.secondaryResetAt = report.secondaryResetAt || 0
                root.primaryWindowDurationMins = report.primaryWindowDurationMins || 0
                root.secondaryWindowDurationMins = report.secondaryWindowDurationMins || 0
            }
        }
    }
}
