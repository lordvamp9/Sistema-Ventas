// AlertCard.qml — Stock warning card
import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string productName: ""
    property string velocity:    "0"
    property int    daysLeft:    0

    radius: 10
    color: "#fff7ed"
    border.color: "#fb923c"
    border.width: 1
    height: 72
    Layout.fillWidth: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: "#ef4444"
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: root.productName
                font.pixelSize: 14
                font.bold: true
                font.family: "Inter"
                color: "#92400e"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.daysLeft >= 9000
                      ? "Sin ventas — stock: revisión"
                      : "Stock crítico · " + root.daysLeft + " días restantes"
                font.pixelSize: 12
                font.family: "Inter"
                color: "#b45309"
            }
        }
    }
}
