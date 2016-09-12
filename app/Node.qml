import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0

import ShaderNodes 1.0

Item {
    id: root

    signal dropReceived(var from, var to)
    signal handleValueChanged()

    property var inputHandles: []
    property var outputHandles: []
    property var allHandles: []
    property var arrayProperties: []
    property string identifier
    property string exportedTypeName
    property string name
    property bool virtualized: exportedTypeName.length < 1

    width: 360
    height: Math.max(inputColumn.y + inputColumn.height, outputColumn.y + outputColumn.height) + 24

    Component.onCompleted: {
    }

    onXChanged: {
        updateHandleConnectionPoints()
    }

    onYChanged: {
        updateHandleConnectionPoints()
    }

    onWidthChanged: {
        updateHandleConnectionPoints()
    }

    onHeightChanged: {
        updateHandleConnectionPoints()
    }

    function updateHandleConnectionPoints() {
        for(var i in allHandles) {
            var handle = allHandles[i]
            handle.connectionPoint = parent.mapFromItem(handle, handle.plug.x + handle.plug.width / 2, handle.plug.y + handle.plug.height / 2)
        }
    }

    function createInputHandle(name, value) {
        var handleComponent = Qt.createComponent("Handle.qml")
        if(handleComponent.status !== Component.Ready) {
            console.log(handleComponent.errorString())
            return
        }
        var glslType = ShaderNodes.glslType(value)
        var properties = {
            name: name,
            identifier: name,
            type: "input",
            node: root,
            value: value,
            defaultValue: value,
            glslType: glslType
        }
        var handle = handleComponent.createObject(inputColumn, properties)
        handle.newHandleClicked.connect(function() {
            var newHandle = createInputHandle(name, value)
            newHandle.arrayBased = true
        })
        handle.dropReceived.connect(function(from) {
            root.dropReceived(from, handle)
        })
        handle.valueChanged.connect(function() {
            root.handleValueChanged()
        })
        inputHandles.push(handle)
        allHandles = inputHandles.concat(outputHandles)
        updateHandleConnectionPoints()
        return handle
    }

    function parseNode(shaderNode) {
        if(!shaderNode) {
            return
        }

        root.exportedTypeName = shaderNode.exportedTypeName
        root.name = shaderNode.name
        root.arrayProperties = shaderNode.arrayProperties

        for(var i in inputHandles) {
            var handle = inputHandles[i]
            handle.destroy()
        }
        for(var i in outputHandles) {
            var handle = outputHandles[i]
            handle.destroy()
        }

        var names = shaderNode.inputNames()

        for(var i in names) {
            var name = names[i]
            var handle = createInputHandle(name, shaderNode[name])
            if(shaderNode.arrayProperties.indexOf(name) > -1) {
                handle.arrayBased = true
            }
        }

        var newOutputHandles = []


        var handleComponent = Qt.createComponent("Handle.qml")
        if(handleComponent.status !== Component.Ready) {
            console.log(handleComponent.errorString())
            return
        }

        var outputHandle = handleComponent.createObject(outputColumn, {name: "result", type: "output", node: root})
        newOutputHandles.push(outputHandle)

        outputHandles = newOutputHandles

        allHandles = inputHandles.concat(outputHandles)

//        object.destroy()

        updateHandleConnectionPoints()
    }


    Rectangle {
        id: background
        anchors.fill: parent
        radius: 6.0
        color: Material.background
    }

    DropShadow {
        anchors.fill: background
        source: background
        radius: 12
        verticalOffset: 4
        horizontalOffset: 2
        samples: 16
    }

    MouseArea {
        anchors.fill: parent
        drag.target: parent
        drag.threshold: 0
    }

    Column {
        id: inputColumn
        anchors {
            left: parent.left
            top: titleText.bottom
            margins: 8
        }
        spacing: 8
    }

    Column {
        id: outputColumn
        anchors {
            right: parent.right
            top: titleText.bottom
            margins: 8
        }
        spacing: 8
    }

    Label {
        id: titleText
        anchors {
            margins: 8
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        text: exportedTypeName ? exportedTypeName : name
    }
}
