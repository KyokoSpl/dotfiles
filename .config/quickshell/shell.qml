//@ pragma IconTheme Papirus
import QtQuick
import Quickshell
import "bar"
import "notifications"
import "osd"
ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panelWin
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 55
            color: "transparent"
            exclusiveZone: implicitHeight
            Bar { id: bar; screenName: modelData.name; anchors.fill: parent }
            AudioPopup {
                anchor.window: panelWin
                anchor.rect.x: bar.rightContainer.x + bar.rightBar.x + bar.rightBar.audioWidget.x + (bar.rightBar.audioWidget.width / 2) - (implicitWidth / 2)
                anchor.rect.y: panelWin.height
                screenName: modelData.name
            }
            BluetoothPopup {
                anchor.window: panelWin
                anchor.rect.x: bar.rightContainer.x + bar.rightBar.x + bar.rightBar.bluetoothWidget.x + (bar.rightBar.bluetoothWidget.width / 2) - (implicitWidth / 2)
                anchor.rect.y: panelWin.height
                screenName: modelData.name
            }
            NetworkPopup {
                anchor.window: panelWin
                anchor.rect.x: bar.rightContainer.x + bar.rightBar.x + bar.rightBar.networkWidget.x + (bar.rightBar.networkWidget.width / 2) - (implicitWidth / 2)
                anchor.rect.y: panelWin.height
                screenName: modelData.name
            }
            SystemPopup {
                anchor.window: panelWin
                anchor.rect.x: bar.rightContainer.x + bar.rightBar.x + bar.rightBar.systemWidget.x + (bar.rightBar.systemWidget.width / 2) - (implicitWidth / 2)
                anchor.rect.y: panelWin.height
                screenName: modelData.name
            }
            LayoutPopup {
                anchor.window: panelWin
                anchor.rect.x: Math.max(0, bar.leftContainer.x + bar.leftBar.x + bar.leftBar.layoutWidget.x + (bar.leftBar.layoutWidget.width / 2) - (implicitWidth / 2))
                anchor.rect.y: panelWin.height
                screenName: modelData.name
                widgetOpen: bar.leftBar.layoutWidget.popupOpen
            }
        }
    }
    Variants {
        model: Quickshell.screens
        NotificationPopup {
            required property var modelData
            screen: modelData
        }
    }
    Variants {
        model: Quickshell.screens
        SessionOSD {
            required property var modelData
            screen: modelData
        }
    }
}
