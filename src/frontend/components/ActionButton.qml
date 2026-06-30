// ActionButton.qml — Reusable premium button
import QtQuick 2.15

Rectangle {
    id: root

    // Public API
    property string text: ""
    property color btnColor:   "#0ea5e9"
    property color textColor:  "#ffffff"
    property int   textSize:   15
    property bool  enabled:    true
    property real  btnRadius:  10

    signal clicked()

    radius: btnRadius
    color: {
        if (!root.enabled)      return Qt.rgba(0.6, 0.6, 0.6, 0.4)
        if (mouseArea.pressed)  return Qt.darker(btnColor, 1.25)
        if (mouseArea.containsMouse) return Qt.darker(btnColor, 1.08)
        return btnColor
    }

    opacity: root.enabled ? 1.0 : 0.6

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.pixelSize: root.textSize
        font.bold: true
        font.family: "Inter"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        elide: Text.ElideRight
        width: parent.width - 12
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { if (root.enabled) root.clicked() }
    }
}
