import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Pill {
    id: root
    pillColor: Colors.red200
    property string screenName: ""
    property int cpuPercent: 0
    property string ramUsed: "0"
    property real prevCpuTotal: 0
    property real prevCpuIdle: 0

    label: "󰻠 " + cpuPercent + "% 󰍛 " + ramUsed + "G"

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const firstLine = text.split("\n")[0]
                const parts = firstLine.trim().split(/\s+/)
                const user = parseInt(parts[1]) || 0
                const nice = parseInt(parts[2]) || 0
                const system = parseInt(parts[3]) || 0
                const idle = parseInt(parts[4]) || 0
                const iowait = parseInt(parts[5]) || 0
                const irq = parseInt(parts[6]) || 0
                const softirq = parseInt(parts[7]) || 0
                const steal = parseInt(parts[8]) || 0

                const totalIdle = idle + iowait
                const total = user + nice + system + idle + iowait + irq + softirq + steal

                if (root.prevCpuTotal > 0) {
                    const totalDiff = total - root.prevCpuTotal
                    const idleDiff = totalIdle - root.prevCpuIdle
                    if (totalDiff > 0)
                        root.cpuPercent = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                }

                root.prevCpuTotal = total
                root.prevCpuIdle = totalIdle
            }
        }
    }

    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let total = 0, available = 0
                const lines = text.split("\n")
                for (const line of lines) {
                    if (line.startsWith("MemTotal:"))
                        total = parseInt(line.split(/\s+/)[1]) || 0
                    else if (line.startsWith("MemAvailable:"))
                        available = parseInt(line.split(/\s+/)[1]) || 0
                }
                if (total > 0) {
                    const usedKb = total - available
                    const usedGb = usedKb / 1048576
                    root.ramUsed = usedGb.toFixed(1)
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
        }
    }

    mouseArea.onClicked: {
        if (SessionState.systemPopupVisible && SessionState.activePopupScreen === root.screenName) {
            SessionState.systemPopupVisible = false
        } else {
            SessionState.closeAllPopups()
            SessionState.activePopupScreen = root.screenName
            SessionState.systemPopupVisible = true
        }
    }
}
