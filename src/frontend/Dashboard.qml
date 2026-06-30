import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 25

        // Header Title
        Text {
            text: "Dashboard | " + settingsManager.storeName
            font.pixelSize: Theme.size3XL
            font.bold: true
            font.family: Theme.font
            color: Theme.textPrimary
        }

        // KPIs Row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            spacing: 20

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "Ventas Hoy"; font.pixelSize: Theme.sizeMD; color: Theme.textSecondary; font.family: Theme.font }
                    Text { text: posController.dailyTransactions.toString(); font.pixelSize: Theme.size3XL; font.bold: true; color: Theme.textPrimary; font.family: Theme.font }
                }
            }

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "Monto Total Hoy"; font.pixelSize: Theme.sizeMD; color: Theme.textSecondary; font.family: Theme.font }
                    Text { text: "$" + posController.dailyTotal.toFixed(0); font.pixelSize: Theme.size3XL; font.bold: true; color: Theme.success; font.family: Theme.font }
                }
            }

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "Productos Vendidos"; font.pixelSize: Theme.sizeMD; color: Theme.textSecondary; font.family: Theme.font }
                    Text { text: posController.dailyItemsCount.toString(); font.pixelSize: Theme.size3XL; font.bold: true; color: Theme.brand; font.family: Theme.font }
                }
            }

            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "Alertas de Stock"; font.pixelSize: Theme.sizeMD; color: Theme.textSecondary; font.family: Theme.font }
                    Text { text: inventorySystem.criticalProductsCount.toString(); font.pixelSize: Theme.size3XL; font.bold: true; color: inventorySystem.criticalProductsCount > 0 ? Theme.danger : Theme.success; font.family: Theme.font }
                }
            }
        }

        // Main Content Row
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Recent Sales Table
            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 65
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "Ventas Recientes"
                        font.pixelSize: Theme.sizeXL
                        font.bold: true
                        font.family: Theme.font
                        color: Theme.textPrimary
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    ListView {
                        id: salesList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: posController.recentSales
                        spacing: 10
                        
                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 50
                            color: Theme.bg
                            radius: 8
                            border.color: Theme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                Text { text: modelData.name; font.pixelSize: Theme.sizeMD; font.family: Theme.font; Layout.fillWidth: true; color: Theme.textPrimary }
                                Text { text: "$" + modelData.price.toFixed(0); font.pixelSize: Theme.sizeMD; font.bold: true; font.family: Theme.font; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight; color: Theme.textPrimary }
                                Text { text: modelData.time; font.pixelSize: Theme.sizeMD; font.family: Theme.font; color: Theme.textSecondary; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }
                }
            }

            // Critical Stock
            SolidCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 35
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "Stock Crítico"
                        font.pixelSize: Theme.sizeXL
                        font.bold: true
                        font.family: Theme.font
                        color: Theme.danger
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    ListModel { id: criticalModel }

                    Connections {
                        target: inventorySystem
                        function onCriticalStockAlert(productName, currentStock, dailyVelocity, estimatedDaysLeft) {
                            // Check if exists to avoid duplicates when running prediction multiple times
                            var found = false;
                            for(var i=0; i<criticalModel.count; ++i) {
                                if (criticalModel.get(i).name === productName) {
                                    found = true;
                                    break;
                                }
                            }
                            if(!found) {
                                criticalModel.append({
                                    "name": productName,
                                    "velocity": dailyVelocity.toFixed(1),
                                    "daysLeft": estimatedDaysLeft
                                });
                            }
                        }
                    }

                    Component.onCompleted: {
                        criticalModel.clear();
                        inventorySystem.runStockPrediction(30, settingsManager.criticalStockDays);
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: criticalModel
                        spacing: 10

                        delegate: AlertCard {
                            productName: model.name
                            velocity: model.velocity
                            daysLeft: model.daysLeft
                        }
                    }
                }
            }
        }
    }
}
