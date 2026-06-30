import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 25

        Text {
            text: "Dashboard | vamp9 POS"
            color: "#0f172a"
            font.pixelSize: 34
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 25

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 65 
                
                Text {
                    anchors.centerIn: parent
                    text: "[ Gráficos de Ventas ]"
                    color: "#94a3b8"
                    font.pixelSize: 18
                }
            }

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 35 
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 15

                    RowLayout {
                        Image {
                            source: "https://www.svgrepo.com/show/521463/alert-circle.svg"
                            sourceSize: Qt.size(24, 24)
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }
                        Text {
                            text: "Stock Crítico"
                            color: "#ef4444" 
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }
                    
                    AlertCard { productName: "Cargador Rapido"; daysLeft: 2; velocity: "12/dia" }
                    AlertCard { productName: "Audifonos Inalambricos"; daysLeft: 4; velocity: "3.5/dia" }
                    
                    Item { Layout.fillHeight: true } 
                }
            }
        }
    }
}
