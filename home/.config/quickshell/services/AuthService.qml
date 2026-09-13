// ╭──────────────────────────────────────────────────────────────────────────╮
// │   A U T H   S E R V I C E                                                 │
// │   local Claude Code and Codex authentication state                        │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Authentication is inferred only from local CLI credential files. The script
// returns booleans and never passes credential values into QML.
Singleton {
    id: root

    property bool claudeAuthenticated: false
    property bool chatgptAuthenticated: false
    property bool ready: false

    Component.onCompleted: root.refresh()

    readonly property Timer poller: Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    function refresh(): void {
        if (!root.query.running)
            root.query.running = true
    }

    function login(service: string): void {
        const command = service === "claude" ? "claude"
            : service === "chatgpt" ? "codex" : ""
        if (command !== "")
            Quickshell.execDetached(["kitty", command])
    }

    readonly property Process query: Process {
        command: ["python3", Quickshell.shellPath("scripts/auth_status.py")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const report = JSON.parse(text)
                    root.claudeAuthenticated = report.claude === true
                    root.chatgptAuthenticated = report.codex === true
                    root.ready = true
                } catch (error) {
                    console.warn("Cannot parse local authentication status:", error)
                }
            }
        }
    }
}
