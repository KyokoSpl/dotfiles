import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Pill {
    id: root
    pillColor: Colors.blueGrey700
    pillForeground: Colors.white
    property string currentLayout: "T"
    property string screenName: ""
    property bool popupOpen: false

    Connections {
        target: SessionState
        function onLayoutPopupVisibleChanged() {
            if (!SessionState.layoutPopupVisible) {
                root.popupOpen = false
            }
        }
    }

    function layoutName(code) {
        if (code === "T")  return "Tile"
        if (code === "S")  return "Stack"
        if (code === "G")  return "Grid"
        if (code === "M")  return "Monocle"
        if (code === "K")  return "Keyed"
        if (code === "CT") return "Center Tile"
        if (code === "RT") return "Right Tile"
        if (code === "VS") return "V-Stack"
        if (code === "VT") return "V-Tile"
        if (code === "VG") return "V-Grid"
        if (code === "VK") return "V-Keyed"
        if (code === "TG") return "Tag Grid"
        return code
    }

    function layoutIcon(code) {
        if (code === "T")  return "󰙀"   // Tile
        if (code === "S")  return "󱒎"   // Stack
        if (code === "G")  return "󰕰"   // Grid
        if (code === "M")  return "󰍉"   // Monocle
        if (code === "K")  return "󰌨"   // Keyed
        if (code === "CT") return "󰕴"   // Center Tile
        if (code === "RT") return "󰁁"   // Right Tile
        if (code === "VS") return "󱒏"   // V-Stack
        if (code === "VT") return "󰯍"   // V-Tile
        if (code === "VG") return "󰕳"   // V-Grid
        if (code === "VK") return "󰌩"   // V-Keyed
        if (code === "TG") return "󱇙"   // Tag Grid
        return "󰙀"
    }

    label: layoutIcon(currentLayout) + " " + layoutName(currentLayout)

    property var allLayouts: []

    Process {
        id: layoutListProc
        command: ["mmsg", "-L"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var result = []
                for (var i = 0; i < lines.length; i++) {
                    var code = lines[i].trim()
                    if (code !== "") result.push(code)
                }
                root.allLayouts = result
            }
        }
    }

    Process {
        id: watchLayoutProc
        command: ["mmsg", "-w", "-l"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                var match = line.match(/(\S+)\s+layout\s+(\S+)/)
                if (match) {
                    var output = match[1]
                    if (root.screenName !== "" && output !== root.screenName) return
                    root.currentLayout = match[2]
                }
            }
        }
    }

    function cycleLayout(delta) {
        if (allLayouts.length === 0) {
            layoutListProc.running = true
            return
        }
        var idx = allLayouts.indexOf(currentLayout)
        if (idx === -1) idx = 0
        idx = (idx + delta + allLayouts.length) % allLayouts.length
        var code = allLayouts[idx]
        currentLayout = code
        var cmd = screenName !== "" ? ["mmsg", "-o", screenName, "-s", "-l", code] : ["mmsg", "-s", "-l", code]
        Quickshell.execDetached(cmd)
    }

    mouseArea.onClicked: {
        if (root.popupOpen) {
            root.popupOpen = false
            SessionState.layoutPopupVisible = false
        } else {
            SessionState.closeAllPopups()
            SessionState.activePopupScreen = root.screenName
            SessionState.layoutPopupVisible = true
            root.popupOpen = true
        }
    }
    mouseArea.onWheel: (wheel) => {
        root.cycleLayout(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
