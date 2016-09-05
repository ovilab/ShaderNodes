import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("ShaderNodes")

    Editor {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.horizontalCenter
            bottom: parent.bottom
        }
    }

    PreviewScene {
        anchors {
            right: parent.right
            top: parent.top
            left: parent.horizontalCenter
            bottom: parent.bottom
        }
    }
}
