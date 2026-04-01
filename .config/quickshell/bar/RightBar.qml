import QtQuick
import qs.bar.widgets

Row {
    spacing: 6

    property string screenName: ""
    property alias audioWidget: audioWidget
    property alias bluetoothWidget: bluetoothWidget
    property alias networkWidget: networkWidget
    property alias systemWidget: systemWidget

    TrayBar          { anchors.verticalCenter: parent.verticalCenter }
    AudioWidget      { id: audioWidget; screenName: parent.screenName; anchors.verticalCenter: parent.verticalCenter }
    BluetoothWidget  { id: bluetoothWidget; screenName: parent.screenName; anchors.verticalCenter: parent.verticalCenter }
    NetworkWidget    { id: networkWidget; screenName: parent.screenName; anchors.verticalCenter: parent.verticalCenter }
    SystemWidget     { id: systemWidget; screenName: parent.screenName; anchors.verticalCenter: parent.verticalCenter }
    DateWidget       { anchors.verticalCenter: parent.verticalCenter }
    SessionWidget    { anchors.verticalCenter: parent.verticalCenter }
}
