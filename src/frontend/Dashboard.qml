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
            text: "Dashboard | Multicosas"
            color: "#ffffff"
            font.pixelSize: 34
            font.bold: true
            
            opacity: 0
            NumberAnimation on opacity { to: 1; duration: 1200; easing.type: Easing.OutCubic }
            NumberAnimation on y { from: -20; to: 0; duration: 1000; easing.type: Easing.OutBack }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 25

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 65 
                
                Text {
                    anchors.centerIn: parent
                    text: "[ Espacio para Gráficos ]"
                    color: "#94a3b8"
                    font.pixelSize: 18
                }
            }

            GlassPanel {
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
                            color: "#f87171" 
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
