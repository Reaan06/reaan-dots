// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C O D E X   S E R V I C E                                            │
// │   usage from the local SQLite database                          │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Codex token usage for the current five-hour block and the last seven
// days, read from the local `state_5.sqlite` database.
//
// `threads` table carries a `tokens_used` column per thread. We aggregate
// by creation time to build block and week totals.
//
// Runs only while subscribed; the first read is a full scan.
Singleton {
    id: root

    // The block is five hours; two-minute resolution is plenty.
    readonly property int pollInterval: 120000

    property int watchers: 0
    property bool available: false
    readonly property bool authenticated: AuthService.chatgptAuthenticated

    // Query once on construction: the bar only builds the module once
    // `available` is true, so nothing would subscribe otherwise.
    Component.onCompleted: root.refresh()

    property real blockStart: 0
    property real blockEnd: 0
    property int blockTokens: 0
    property int blockMessages: 0
    property int weekTokens: 0
    property int weekMessages: 0
    property int peakBlockTokens: 0
    property int peakWeekTokens: 0

    // "resets in 3 h 53 min"
    readonly property string resetsIn: {
        if (!root.available)
            return ""
        const minutes = Math.ceil(root.remaining / 60000)
        if (minutes <= 0)
            return "resets now"
        const hours = Math.floor(minutes / 60)
        return hours > 0
            ? `resets in ${hours} h ${minutes % 60} min`
            : `resets in ${minutes} min`
    }

    // Wall clock, so the countdown advances between polls.
    readonly property SystemClock clock: SystemClock {
        precision: SystemClock.Minutes
        enabled: root.watchers > 0
    }

    readonly property real remaining: {
        if (!root.available)
            return 0
        return Math.max(0, root.blockEnd * 1000 - root.clock.date.getTime())
    }

    readonly property real elapsed: {
        const span = root.blockEnd - root.blockStart
        if (span <= 0)
            return 0
        return Math.max(0, Math.min(1, 1 - root.remaining / (span * 1000)))
    }

    readonly property real gauge: root.elapsed

    // 1.2k, 34k, 8.7M.
    function compact(tokens: int): string {
        if (tokens >= 1000000)
            return `${(tokens / 1000000).toFixed(1)}M`
        if (tokens >= 1000)
            return `${Math.round(tokens / 1000)}k`
        return `${tokens}`
    }

    function messages(count: int): string {
        return `${root.compact(count)} message${count === 1 ? "" : "s"}`
    }

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
                root.blockStart = report.blockStart
                root.blockEnd = report.blockEnd
                root.blockTokens = report.blockTokens
                root.blockMessages = report.blockMessages
                root.weekTokens = report.weekTokens
                root.weekMessages = report.weekMessages
                root.peakBlockTokens = report.peakBlockTokens
                root.peakWeekTokens = report.peakWeekTokens
            }
        }
    }
}
