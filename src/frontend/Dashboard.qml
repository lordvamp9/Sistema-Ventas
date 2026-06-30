import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "components"

Item {
    id: root
    property var themeRef: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 0

        // ── Header ───────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 20

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "Dashboard"
                    font.pixelSize: 30
                    font.bold: true
                    font.family: "Inter"
                    color: themeRef ? themeRef.textPrimary : "#0f172a"
                }
                Text {
                    text: settingsManager ? settingsManager.storeName : "vamp9 POS"
                    font.pixelSize: 15
                    font.family: "Inter"
                    color: themeRef ? themeRef.textSecondary : "#475569"
                }
            }

            Text {
                id: clockText
                font.pixelSize: 17
                font.family: "Inter"
                color: themeRef ? themeRef.textSecondary : "#475569"
                horizontalAlignment: Text.AlignRight
            }

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd d MMM  HH:mm:ss")
                Component.onCompleted: clockText.text = Qt.formatDateTime(new Date(), "ddd d MMM  HH:mm:ss")
            }
        }

        // ── KPI Cards Row ────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            height: 100
            spacing: 16

            KPICard {
                label: "Ventas Hoy"
                value: posController ? posController.dailyTransactions.toString() : "0"
                accentColor: "#0ea5e9"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            KPICard {
                label: "Ingresos Hoy"
                value: posController ? ("$" + posController.dailyTotal.toFixed(0)) : "$0"
                accentColor: "#16a34a"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            KPICard {
                label: "Items Vendidos"
                value: posController ? posController.dailyItemsCount.toString() : "0"
                accentColor: "#38bdf8"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            KPICard {
                label: "Alertas de Stock"
                value: inventorySystem ? inventorySystem.criticalProductsCount.toString() : "0"
                accentColor: (inventorySystem && inventorySystem.criticalProductsCount > 0) ? "#dc2626" : "#16a34a"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        Item { height: 16 }

        // ── Main area: Recent Sales + Critical Stock ─────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Recent Sales
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Text {
                        text: "Últimas Ventas"
                        font.pixelSize: 20
                        font.bold: true
                        font.family: "Inter"
                        color: "#0f172a"
                    }

                    // Table header
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: "#f8fafc"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 0
                            Text { text: "Producto"; font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.fillWidth: true }
                            Text { text: "Monto";    font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 90;  horizontalAlignment: Text.AlignRight }
                            Text { text: "Hora";     font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 70;  horizontalAlignment: Text.AlignRight }
                        }
                    }

                    ListView {
                        id: recentSalesList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: posController ? posController.recentSales : []
                        spacing: 2

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 44
                            radius: 6
                            color: index % 2 === 0 ? "#ffffff" : "#f8fafc"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 0
                                Text { text: modelData.name;  font.pixelSize: 14; font.family: "Inter"; color: "#0f172a"; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: "$" + modelData.price.toFixed(0); font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#16a34a"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                                Text { text: modelData.time;  font.pixelSize: 13; font.family: "Inter"; color: "#94a3b8"; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: recentSalesList.count === 0
                            text: "Sin ventas hoy"
                            font.pixelSize: 14; font.family: "Inter"; color: "#94a3b8"
                        }
                    }
                }
            }

            // Critical Stock panel
            Rectangle {
                Layout.fillHeight: true
                width: 280
                radius: 12
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Stock Crítico"
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Inter"
                            color: "#dc2626"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 28; height: 20; radius: 10
                            color: "#fee2e2"
                            Text {
                                anchors.centerIn: parent
                                text: criticalListView.count.toString()
                                font.pixelSize: 11; font.bold: true; font.family: "Inter"; color: "#dc2626"
                            }
                        }
                    }

                    ListModel { id: criticalModel }

                    Connections {
                        target: inventorySystem
                        function onCriticalStockAlert(productName, currentStock, dailyVelocity, estimatedDaysLeft) {
                            for (var i = 0; i < criticalModel.count; i++) {
                                if (criticalModel.get(i).pName === productName) return
                            }
                            criticalModel.append({ pName: productName, pDays: estimatedDaysLeft, pStock: currentStock })
                        }
                    }

                    Component.onCompleted: {
                        criticalModel.clear()
                        if (inventorySystem) {
                            inventorySystem.runStockPrediction(30, settingsManager ? settingsManager.criticalStockDays : 3)
                        }
                    }

                    ListView {
                        id: criticalListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: criticalModel
                        spacing: 8

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 64
                            radius: 8
                            color: "#fff7ed"
                            border.color: "#fb923c"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Rectangle { width: 6; height: 6; radius: 3; color: "#ef4444"; Layout.alignment: Qt.AlignVCenter }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text { text: model.pName; font.pixelSize: 13; font.bold: true; font.family: "Inter"; color: "#92400e"; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Text { text: model.pDays >= 9000 ? "Sin rotación" : (model.pDays + " días · stock: " + model.pStock); font.pixelSize: 11; font.family: "Inter"; color: "#b45309" }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: criticalListView.count === 0
                            text: "✓ Todo en orden"
                            font.pixelSize: 14; font.family: "Inter"; color: "#16a34a"
                        }
                    }
                }
            }
        }
    }

    // ── KPI Card inline component ─────────────────────────────
    component KPICard: Rectangle {
        property string label:       ""
        property string value:       "0"
        property color  accentColor: "#0ea5e9"

        radius: 12
        color: "#ffffff"
        border.color: "#e2e8f0"
        border.width: 1

        // Top accent stripe
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 4
            radius: 2
            color: accentColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            anchors.topMargin: 14
            spacing: 4

            Text {
                text: label
                font.pixelSize: 12; font.family: "Inter"; color: "#475569"
            }
            Text {
                text: value
                font.pixelSize: 28; font.bold: true; font.family: "Inter"
                color: accentColor
            }
        }
    }
}
