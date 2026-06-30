import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Window {
    width: 1280
    height: 720
    visible: true
    title: "vamp9 POS - Profesional"
    color: "#f1f5f9" // Light background (slate-100)

    AudioSystem { id: audioSystem }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationSidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            onCurrentViewChanged: stackLayout.currentIndex = viewIndex
        }

        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            Dashboard { id: dashboardView }
            POSView { id: posView; property var audioSystemRef: audioSystem }
            AdminView { id: adminView; property var audioSystemRef: audioSystem }
        }
    }
}
