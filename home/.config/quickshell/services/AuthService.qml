// ╭──────────────────────────────────────────────────────────────────────────╮
// │   A U T H   S E R V I C E                                                 │
// │   local Claude Code and Codex authentication state                        │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Authentication is inferred only from local CLI status probes. The script
// returns booleans and never passes credential values into QML.
Singleton {
    id: root

    property bool claudeAuthenticated: false
    property bool chatgptAuthenticated: false
    property bool ready: false
    property bool loggingOut: false
    property string pendingLogin: ""
    property int loginChecks: 0
    property int logoutChecks: 0

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
        if (service === "claude")
            Quickshell.execDetached(["kitty", "claude"])
        else if (service === "chatgpt")
            Quickshell.execDetached(["kitty", "codex", "login"])
        else
            return

        root.pendingLogin = service
        root.loginChecks = 0
        root.refresh()
        root.loginPoller.start()
    }

    function logout(service: string): void {
        if (service !== "chatgpt" || root.loggingOut)
            return

        root.loggingOut = true
        root.logoutChecks = 0
        root.logoutProcess.command = ["codex", "logout"]
        root.logoutProcess.running = true
    }

    readonly property Timer loginPoller: Timer {
        interval: 2000
        repeat: true

        onTriggered: {
            root.refresh()
            root.loginChecks += 1
            const authenticated = root.pendingLogin === "claude"
                ? root.claudeAuthenticated : root.chatgptAuthenticated
            if (authenticated || root.loginChecks >= 30) {
                stop()
                root.pendingLogin = ""
            }
        }
    }

    readonly property Timer logoutPoller: Timer {
        interval: 500
        repeat: true

        onTriggered: {
            root.refresh()
            root.logoutChecks += 1
            if (!root.chatgptAuthenticated || root.logoutChecks >= 20) {
                stop()
                root.loggingOut = false
            }
        }
    }

    readonly property Process logoutProcess: Process {
        onExited: {
            root.refresh()
            root.logoutPoller.start()
        }
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
