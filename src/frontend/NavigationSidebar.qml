import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: root

    property var themeRef: null
    property int activeIndex: 0

    signal navSelected(int index)

    color: themeRef ? themeRef.sidebarBg : "#075985"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Logo / Brand ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 72
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: "vamp9"
                    font.pixelSize: 26
                    font.bold: true
                    font.family: "Inter"
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "POINT OF SALE"
                    font.pixelSize: 10
                    font.family: "Inter"
                    font.letterSpacing: 2
                    color: "#7dd3fc"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.15)
            Layout.leftMargin: 20
            Layout.rightMargin: 20
        }

        Item { height: 12 }

        // ── Nav items ────────────────────────────────────────
        NavItem {
            label: "Dashboard"
            iconChar: "⊞"
            index: 0
            active: root.activeIndex === 0
            onSelected: { root.activeIndex = 0; root.navSelected(0) }
        }
        NavItem {
            label: "Caja (POS)"
            iconChar: "⊟"
            index: 1
            active: root.activeIndex === 1
            onSelected: { root.activeIndex = 1; root.navSelected(1) }
        }
        NavItem {
            label: "Inventario"
            iconChar: "☰"
            index: 2
            active: root.activeIndex === 2
            onSelected: { root.activeIndex = 2; root.navSelected(2) }
        }
        NavItem {
            label: "Configuración"
            iconChar: "⚙"
            index: 3
            active: root.activeIndex === 3
            onSelected: { root.activeIndex = 3; root.navSelected(3) }
        }

        Item { Layout.fillHeight: true }

        // ── Footer / version ─────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        Text {
            text: "v2.0  ·  vamp9 POS"
            font.pixelSize: 11
            font.family: "Inter"
            color: "#7dd3fc"
            Layout.alignment: Qt.AlignHCenter
            topPadding: 12
            bottomPadding: 12
        }
    }

    // ── NavItem component ────────────────────────────────────
    component NavItem: Item {
        id: navItem
        property string label:    ""
        property string iconChar: ""
        property int    index:    0
        property bool   active:   false

        signal selected()

        Layout.fillWidth: true
        height: 48

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            radius: 8
            color: navItem.active
                   ? Qt.rgba(1, 1, 1, 0.18)
                   : (navHover.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : "transparent")
            Behavior on color { ColorAnimation { duration: 120 } }

            // Active indicator bar
            Rectangle {
                visible: navItem.active
                width: 3
                height: 24
                radius: 2
                color: "#38bdf8"
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 12

                Text {
                    text: navItem.iconChar
                    font.pixelSize: 18
                    color: navItem.active ? "#ffffff" : "#bae6fd"
                    Layout.preferredWidth: 20
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: navItem.label
                    font.pixelSize: 14
                    font.bold: navItem.active
                    font.family: "Inter"
                    color: navItem.active ? "#ffffff" : "#bae6fd"
                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            id: navHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navItem.selected()
        }
    }
}
