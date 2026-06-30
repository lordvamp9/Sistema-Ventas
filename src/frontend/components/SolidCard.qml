import QtQuick
import QtQuick.Effects

Item {
    id: root
    property int radius: 12
    property color backgroundColor: "#FFFFFF"
    property bool hasShadow: true
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.color: "#E2E8F0"
        border.width: 1
        layer.enabled: root.hasShadow
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#1A000000"
            shadowBlur: 0.4
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 0
        }
    }
}
