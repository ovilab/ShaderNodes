import QtQuick 2.0

Rectangle {
    width: 160
    height: 120

    color: "red"

    MouseArea {
        anchors.fill: parent
        drag.target: parent
    }
}
