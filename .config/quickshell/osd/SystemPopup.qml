import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: root
    visible: animState !== "closed"
    implicitWidth: 260
    implicitHeight: 600
    color: "transparent"

    property string animState: "closed"
    property string screenName: ""
    property int cpuPercent: 0
    property real prevCpuTotal: 0
    property real prevCpuIdle: 0
    property string ramUsed: "0"
    property string ramTotal: "0"
    property int ramPercent: 0
    property string uptime: ""
    property string loadAvg: ""
    property int cpuCores: 0
    property var topProcs: []

    Connections {
        target: SessionState
        function onSystemPopupVisibleChanged() {
            if (SessionState.systemPopupVisible && SessionState.activePopupScreen === root.screenName) {
                refresh()
                animState = "open"
            } else if (animState === "open") {
                animState = "closing"
            }
        }
    }

    function refresh() {
        cpuProc.running = true
        ramProc.running = true
        uptimeProc.running = true
        loadProc.running = true
        topProc.running = true
    }

    Timer {
        interval: 3000
        running: root.animState === "open"
        repeat: true
        onTriggered: refresh()
    }

    // ── CPU ──
    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n")
                // Count cores
                var cores = 0
                for (var j = 1; j < lines.length; j++) {
                    if (lines[j].startsWith("cpu")) cores++
                    else break
                }
                root.cpuCores = cores

                const parts = lines[0].trim().split(/\s+/)
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

    // ── RAM ──
    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        running: false
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
                    root.ramUsed = (usedKb / 1048576).toFixed(1)
                    root.ramTotal = (total / 1048576).toFixed(1)
                    root.ramPercent = Math.round(100 * usedKb / total)
                }
            }
        }
    }

    // ── Uptime ──
    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const secs = parseInt(text.split(" ")[0]) || 0
                const h = Math.floor(secs / 3600)
                const m = Math.floor((secs % 3600) / 60)
                root.uptime = h + "h " + m + "m"
            }
        }
    }

    // ── Load average ──
    Process {
        id: loadProc
        command: ["cat", "/proc/loadavg"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                root.loadAvg = parts[0] + " " + parts[1] + " " + parts[2]
            }
        }
    }

    // ── Top processes ──
    Process {
        id: topProc
        command: ["ps", "-eo", "comm,%cpu,%mem", "--sort=-%cpu", "--no-headers"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                var result = []
                for (var i = 0; i < Math.min(5, lines.length); i++) {
                    const parts = lines[i].trim().split(/\s+/)
                    if (parts.length >= 3) {
                        result.push({
                            name: parts[0],
                            cpu: parts[1],
                            mem: parts[2]
                        })
                    }
                }
                root.topProcs = result
            }
        }
    }

    function barColor(percent) {
        if (percent >= 80) return Colors.red200
        if (percent >= 50) return Colors.orange200
        return Colors.green200
    }

    Rectangle {
        id: innerRect
        width: parent.width
        height: column.implicitHeight + 20
        Behavior on height {
            SmoothedAnimation { velocity: 800; easing.type: Easing.OutExpo }
        }

        y: 0
        opacity: 1.0

        states: [
            State {
                name: "open"
                when: root.animState === "open"
                PropertyChanges { target: innerRect; y: 0; opacity: 1.0 }
            },
            State {
                name: "closing"
                when: root.animState === "closing"
                PropertyChanges { target: innerRect; y: -20; opacity: 0.0 }
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "open"
                SequentialAnimation {
                    PropertyAction { target: innerRect; property: "y"; value: -20 }
                    PropertyAction { target: innerRect; property: "opacity"; value: 0.0 }
                    ParallelAnimation {
                        NumberAnimation { target: innerRect; property: "y"; to: 0; duration: 250; easing.type: Easing.OutExpo }
                        NumberAnimation { target: innerRect; property: "opacity"; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
                    }
                }
            },
            Transition {
                from: "*"; to: "closing"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: innerRect; property: "y"; to: -20; duration: 180; easing.type: Easing.InCubic }
                        NumberAnimation { target: innerRect; property: "opacity"; to: 0.0; duration: 150; easing.type: Easing.InCubic }
                    }
                    ScriptAction { script: root.animState = "closed" }
                }
            }
        ]

        radius: 10
        color: Colors.grey900
        border.color: Colors.red200
        border.width: 2
        clip: true

        Column {
            id: column
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
            spacing: 4

            // ── CPU usage ──
            Rectangle {
                width: parent.width; height: 50; radius: 6; color: Colors.grey800
                Column {
                    anchors { fill: parent; margins: 8 }
                    spacing: 4
                    Row {
                        width: parent.width
                        Text {
                            text: "󰻠 CPU"
                            font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            color: Colors.grey200
                        }
                        Item { width: parent.width - cpuLabel.implicitWidth - cpuValText.implicitWidth; height: 1 }
                        Text {
                            id: cpuValText
                            text: root.cpuPercent + "%"
                            font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            color: root.barColor(root.cpuPercent)
                        }
                    }
                    Rectangle {
                        id: cpuLabel
                        width: parent.width; height: 8; radius: 4; color: Colors.grey700
                        Rectangle {
                            width: parent.width * (root.cpuPercent / 100)
                            height: parent.height; radius: 4
                            color: root.barColor(root.cpuPercent)
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }
                }
            }

            // ── RAM usage ──
            Rectangle {
                width: parent.width; height: 50; radius: 6; color: Colors.grey800
                Column {
                    anchors { fill: parent; margins: 8 }
                    spacing: 4
                    Row {
                        width: parent.width
                        Text {
                            text: "󰍛 RAM"
                            font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            color: Colors.grey200
                        }
                        Item { width: parent.width - ramLabel.implicitWidth - ramValText.implicitWidth; height: 1 }
                        Text {
                            id: ramValText
                            text: root.ramUsed + " / " + root.ramTotal + "G"
                            font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            color: root.barColor(root.ramPercent)
                        }
                    }
                    Rectangle {
                        id: ramLabel
                        width: parent.width; height: 8; radius: 4; color: Colors.grey700
                        Rectangle {
                            width: parent.width * (root.ramPercent / 100)
                            height: parent.height; radius: 4
                            color: root.barColor(root.ramPercent)
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }
                }
            }

            // ── System info ──
            Rectangle {
                width: parent.width; height: infoCol.implicitHeight + 16; radius: 6; color: Colors.grey800
                Column {
                    id: infoCol
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                    spacing: 2
                    Row {
                        spacing: 8
                        Text { text: "󰔟"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey400; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Uptime: " + root.uptime; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey300; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Row {
                        spacing: 8
                        Text { text: "󰘚"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey400; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Cores: " + root.cpuCores; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey300; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Row {
                        spacing: 8
                        Text { text: "󰊚"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey400; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Load: " + root.loadAvg; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey300; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // ── Divider ──
            Rectangle { width: parent.width; height: 1; color: Colors.grey800 }

            // ── Top processes header ──
            Row {
                height: 20; leftPadding: 4; spacing: 6
                Text { text: "󰓅"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; color: Colors.red200; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Top Processes"; font.pixelSize: 12; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey300; anchors.verticalCenter: parent.verticalCenter }
            }

            // ── Top processes list ──
            Repeater {
                model: root.topProcs
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: column.width; height: 26; radius: 4; color: Colors.grey800
                    Row {
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 8; rightMargin: 8 }
                        spacing: 6
                        Text {
                            text: modelData.name
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                            color: Colors.grey200
                            elide: Text.ElideRight
                            width: parent.width - cpuText.implicitWidth - memText.implicitWidth - 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: cpuText
                            text: modelData.cpu + "%"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                            color: Colors.red200
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: memText
                            text: modelData.mem + "%"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                            color: Colors.orange200
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Item { width: 1; height: 2 }

            // ── Open btop ──
            Rectangle {
                width: parent.width; height: 34; radius: 6; color: Colors.grey800

                Rectangle {
                    width: 3; height: parent.height - 10; radius: 2
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    color: Colors.grey500
                }
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8
                    Text {
                        text: ""
                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey400
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Open btop..."
                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey400
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        Quickshell.execDetached(["ghostty", "--title=btop", "-e", "btop"])
                        SessionState.systemPopupVisible = false
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
}
