import QtQuick

Item {
    id: root
    property int radius: 8
    property color backgroundColor: "#ffffff"

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.color: "#e2e8f0"
        border.width: 1

        // Flat design for professional POS
    }
}
