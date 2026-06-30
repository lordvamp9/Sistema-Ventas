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
    color: Theme.surface
    border.color: Theme.danger
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        Image {
            source: "qrc:/vamp9/Vamp9POS/src/assets/icons/alert-circle.svg"
            sourceSize: Qt.size(28, 28)
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: root.productName
                color: Theme.textPrimary
                font.pixelSize: Theme.sizeMD
                font.bold: true
                font.family: Theme.font
            }
            Text {
                text: "Velocidad: " + root.velocity + " | Restan: " + root.daysLeft + " dias"
                color: Theme.textSecondary
                font.pixelSize: Theme.sizeSM
                font.family: Theme.font
            }
        }
    }
}
