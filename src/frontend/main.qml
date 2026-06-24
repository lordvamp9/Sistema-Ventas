import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Window {
    width: 1280
    height: 720
    visible: true
    title: "vamp9 POS"
    color: "#0f172a" 

    AudioSystem { id: audioSystem }

    Rectangle {
        width: 600; height: 600; radius: 300
        color: "#3b82f6"; opacity: 0.15
        x: -150; y: -150
        NumberAnimation on rotation { from: 0; to: 360; duration: 20000; loops: Animation.Infinite }
    }
    Rectangle {
        width: 500; height: 500; radius: 250
        color: "#ec4899"; opacity: 0.15
        anchors.right: parent.right; anchors.bottom: parent.bottom
        NumberAnimation on x { to: parent.width - 400; duration: 15000; loops: Animation.Infinite; easing.type: Easing.InOutSine }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationSidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 250
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
