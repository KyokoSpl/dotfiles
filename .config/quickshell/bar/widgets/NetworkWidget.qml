import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Pill {
    id: root
    pillColor: PanelColors.network
    property string screenName: ""
    property string ssid: ""
    property bool wifiConnected: false
    property bool ethConnected: false
    property int signal: 0

    function signalIcon() {
        if (signal >= 80) return "󰤨"
        else if (signal >= 60) return "󰤥"
        else if (signal >= 40) return "󰤢"
        else if (signal >= 20) return "󰤟"
        else return "󰤯"
    }

    label: {
        if (!wifiConnected && !ethConnected) return "󰤭"
        if (ethConnected && !wifiConnected) return "󰈀 Wired"
        if (ethConnected && wifiConnected) return "󰈀 " + signalIcon() + " " + ssid.substring(0, 8)
        return signalIcon() + " " + ssid.substring(0, 10)
    }

    Process {
        id: refreshProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "dev"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let hasWifi = false
                let hasEth = false
                let activeSsid = ""
                
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":")
                    if (parts.length >= 2) {
                        const type = parts[0]
                        const state = parts[1]
                        const conn = parts.length > 2 ? parts[2] : ""
                        
                        if (state.startsWith("connected")) {
                            if (type === "wifi") {
                                hasWifi = true
                                activeSsid = conn
                            } else if (type === "ethernet") {
                                hasEth = true
                            }
                        }
                    }
                }
                
                root.ethConnected = hasEth
                root.wifiConnected = hasWifi
                root.ssid = activeSsid
                if (hasWifi) {
                    signalProc.running = true
                } else {
                    root.signal = 0
                }
            }
        }
    }

    Process {
        id: signalProc
        command: ["nmcli", "-g", "ACTIVE,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                for (const line of lines) {
                    const parts = line.split(":")
                    if (parts[0] === "yes") {
                        root.signal = parseInt(parts[1]) || 0
                        return
                    }
                }
            }
        }
    }


    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: refreshProc.running = true
    }

    mouseArea.onClicked: {
        if (SessionState.networkPopupVisible && SessionState.activePopupScreen === root.screenName) {
            SessionState.networkPopupVisible = false
        } else {
            SessionState.closeAllPopups()
            SessionState.activePopupScreen = root.screenName
            SessionState.networkPopupVisible = true
        }
    }
}
