import QtQuick 2.0

Item {
    id: root

    signal dropped

    property Handle from
    property Handle to

    property bool valid: (from && to) ? true : false

    property point startPoint: valid ? from.connectionPoint : Qt.point(0, 0)
    property point endPoint: valid ? to.connectionPoint : Qt.point(0, 0)

    BezierCurve {
        id: sCurve
        startPoint: root.startPoint
        endPoint: Qt.point(dragHandle.x + dragHandle.width / 2, dragHandle.y + dragHandle.height / 2)
        controlPoint1: Qt.point(startPoint.x + 50, startPoint.y)
        controlPoint2: Qt.point(endPoint.x - 50, endPoint.y)
        color: valid ? "green" : "red"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: rect

        drag.target: dragHandle

        onReleased: {
            dragHandle.Drag.drop()
            root.dropped()
        }
    }

    Rectangle {
        id: rect
        x: root.endPoint.x - width / 2
        y: root.endPoint.y - height / 2
        width: 16
        height: width
        color: "pink"
    }

    Rectangle {
        id: dragHandle

        property var handle: from

        anchors {
            horizontalCenter: rect.horizontalCenter
            verticalCenter: rect.verticalCenter
        }
        color: "brown"
        width: 12
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
