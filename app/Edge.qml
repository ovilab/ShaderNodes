import QtQuick 2.0
import QtQuick.Controls.Material 2.0

Item {
    id: root

    signal dropped

    property Handle from
    property Handle to

    property bool valid: (from && to) ? true : false

    property point startPoint: valid ? from.connectionPoint : Qt.point(0, 0)
    property point endPoint: valid ? to.connectionPoint : Qt.point(0, 0)

    SCurve {
        id: sCurve
        startPoint: root.startPoint
        endPoint: Qt.point(dragHandle.x + dragHandle.width / 2, dragHandle.y + dragHandle.height / 2)
        color: Material.foreground
    }

    MouseArea {
        id: mouseArea
        anchors.fill: reference

        drag.target: dragHandle
        drag.threshold: 0

        onReleased: {
            dragHandle.Drag.drop()
            root.dropped()
        }
    }

    Item {
        id: reference
        x: root.endPoint.x - width / 2
        y: root.endPoint.y - height / 2
        width: 16
        height: width
    }

    Item {
        id: dragHandle

        property var handle: from
        property var edge: root

        anchors {
            horizontalCenter: reference.horizontalCenter
            verticalCenter: reference.verticalCenter
        }
        width: 24
        height: width

        Drag.keys: ["edge"]
        Drag.active: mouseArea.drag.active
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        states: State {
            when: mouseArea.drag.active
            ParentChange { target: dragHandle; parent: root.parent }
            AnchorChanges { target: dragHandle; anchors.verticalCenter: undefined; anchors.horizontalCenter: undefined }
        }
    }
}
