import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string productName: ""
    property int daysLeft: 0
    property string velocity: ""

    Layout.fillWidth: true
    height: 80
    radius: 12
    color: Qt.rgba(255, 255, 255, 0.08)
    border.color: Qt.rgba(248, 113, 113, 0.3)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        Image {
            source: "https://www.svgrepo.com/show/521463/alert-circle.svg"
            sourceSize: Qt.size(28, 28)
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: root.productName
                color: "#ffffff"
                font.pixelSize: 16
                font.bold: true
            }
            Text {
                text: "Velocidad: " + root.velocity + " | Restan: " + root.daysLeft + " dias"
                color: "#94a3b8"
                font.pixelSize: 12
            }
        }
    }
}
