import QtQuick

Item {
    id: root
    property int radius: 24

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        color: Qt.rgba(255, 255, 255, 0.05) 
        border.color: Qt.rgba(255, 255, 255, 0.15)
        border.width: 1
    }
}
