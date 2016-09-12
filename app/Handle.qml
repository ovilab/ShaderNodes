import QtQuick 2.0
import QtQuick.Controls 2.0

Item {
    id: root

    signal newHandleClicked
    signal dropReceived(var from)

    property alias plug: plug

    property bool occupied: false
    property string name
    property string identifier
    property string type: "input"
    property Node node
    property point connectionPoint: Qt.point(500, 500)
    property int index: -1
    property bool arrayBased: false
    property var value
    property var defaultValue
    property string glslType

    width: 120
    height: 24

    Plug {
        id: plug

        anchors {
            left: type === "input" ? parent.left : undefined
            right: type === "input" ? undefined : parent.right
        }

        height: parent.height
        color: occupied ? "yellow" : "purple"
    }

    Text {
        id: nameText
        anchors {
            left: type === "input" ? plug.right : undefined
            right: type === "input" ? undefined : plug.left
            verticalCenter: parent.verticalCenter
            margins: 8
        }

        text: name
    }

    MouseArea {
        id: mouseArea

        enabled: root.type === "output"

        anchors.fill: parent
        drag.target: dragHandle

        onReleased: dragHandle.Drag.drop()
    }

    Rectangle {
        anchors {
            left: sliderText.right
            verticalCenter: nameText.verticalCenter
        }

        visible: type === "input" && arrayBased
        width: 24
        height: 24

        MouseArea {
            anchors.fill: parent
            onClicked: {
                newHandleClicked()
            }
        }
        Text {
            anchors.centerIn: parent
            text: "+"
        }
    }

    DropArea {
        id: dragTarget

        anchors.fill: parent
        enabled: type === "input"
        keys: ["handle", "edge"]
        states: [
            State {
                when: dragTarget.containsDrag
                PropertyChanges {
                    target: plug
                    color: "grey"
                }
            }
        ]
        onDropped: {
            if(drag.source.handle.node === root.node) {
                console.log("Cannot connect to the same node")
                return
            }

            dropReceived(drag.source.handle)
        }
    }

    Slider {
        id: slider
        visible: type === "input" && !root.occupied && glslType == "float"
        anchors {
            left: nameText.right
        }
        width: 64
        value: visible ? root.value : 0

        Binding {
            target: slider.visible ? root : null
            property: "value"
            value: slider.value
        }
    }

    Text {
        id: sliderText
        anchors {
            left: slider.right
        }
        visible: slider.visible
        text: slider.value.toFixed(1)
    }

    Rectangle {
        id: dragHandle

        property var handle: root

        anchors {
            verticalCenter: plug.verticalCenter
            horizontalCenter: plug.horizontalCenter
        }

        width: 16
        height: 16
        radius: 8
        color: "blue"
        visible: type === "output"

        Drag.keys: ["handle"]
        Drag.active: mouseArea.drag.active
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        states: State {
            when: mouseArea.drag.active
            ParentChange { target: dragHandle; parent: node.parent }
            AnchorChanges { target: dragHandle; anchors.verticalCenter: undefined; anchors.horizontalCenter: undefined }
        }
    }
}
