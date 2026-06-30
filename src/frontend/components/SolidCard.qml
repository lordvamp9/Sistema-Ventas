// SolidCard.qml - A clean elevated card component
import QtQuick 2.15

Rectangle {
    id: root

    // Public API
    property color cardColor: "#ffffff"
    property bool elevated: true

    color: cardColor
    radius: 12

    // Subtle border
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.color: "#e2e8f0"
        border.width: 1
    }

    // Drop shadow using layered rectangles (no MultiEffect needed)
    layer.enabled: elevated
    layer.effect: null

    // We simulate shadow with a behind rectangle in the parent — callers wrap if needed.
    // Simple approach: just use border and slight background tint
}
