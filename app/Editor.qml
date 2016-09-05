import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

Rectangle {
    id: root

    property var nodes: []
    property var edges: []

    Component.onCompleted: {
        var nodeComponent = Qt.createComponent("Node.qml")

        nodeComponent.createObject(workspace, {x: 10, y: 10})
        nodeComponent.createObject(workspace, {x: 200, y: 200})
        nodeComponent.createObject(workspace, {x: 300, y: 400})
    }
    
    Flickable {
        id: workspaceFlickable
        
        anchors.fill: parent
        
        contentHeight: workspace.height
        contentWidth: workspace.width
        
        ScrollBar.vertical: ScrollBar {}
        ScrollBar.horizontal: ScrollBar {}
        
        Item {
            id: workspace
            
            width: 3840
            height: 2160
        }
    }
}
