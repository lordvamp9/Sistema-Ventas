import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string text: ""
    property color buttonColor: "#0ea5e9"
    property color textColor: "#ffffff"
    property int textSize: 18
    signal clicked()
    
    radius: 8
    color: mouseArea.pressed ? Qt.darker(buttonColor, 1.2) : buttonColor
    
    Behavior on color { ColorAnimation { duration: 80 } }
    
    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.pixelSize: root.textSize
        font.bold: true
        font.family: "Inter"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
