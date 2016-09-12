import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import ShaderNodes 1.0

Rectangle {
    id: root

    property var nodes: []
    property var edges: []
    property Node finalNode

    property var outputNode

    property ShaderBuilderMaterial shaderBuilderMaterial
    property ShaderBuilder shaderBuilder: shaderBuilderMaterial.fragment
    property int indentLevel: 0
    property string output

    clip: true

    Component.onCompleted: {
        var addNode = Qt.createQmlObject("import ShaderNodes 1.0\nAdd {}", root, "Add")
        var mixNode = Qt.createQmlObject("import ShaderNodes 1.0\nMix {}", root, "Mix")
        var standardNode = Qt.createQmlObject("import ShaderNodes 1.0\nStandardMaterial {}", root, "StandardMaterial")

        var offset = 100
        for(var i in shaderBuilder.inputs) {
            var input = shaderBuilder.inputs[i]
            var node = createNode(input, {x: 10, y: 10 + offset, identifier: "shaderBuilder.inputs[" + i + "]"})
            offset += 100
        }

        var mix = createNode(mixNode, {x: 400, y: 10})
        var standardMaterial = createNode(standardNode, {x: 800, y: 400})

        finalNode = standardMaterial

        createEdge(nodes[0].outputHandles[0], mix.inputHandles[0])
        createEdge(nodes[2].outputHandles[0], mix.inputHandles[1])
        createEdge(mix.outputHandles[0], standardMaterial.inputHandles[0])

        outputNode = nodes[2]

        generate()
    }

    function createEdge(from, to) {
        var edgeComponent = Qt.createComponent("Edge.qml")
        var edge = edgeComponent.createObject(workspace, {from: from, to: to})
        edge.dropped.connect(function() {
            deleteEdge(edge)
            generate()
        })
        edge.to.occupied = true
        edges.push(edge)
        return edge
    }

    function deleteEdge(edge) {
        edge.to.occupied = false
        edges.splice(edges.indexOf(edge), 1)
        edge.destroy()
    }

    function createNode(shaderNode, properties) {
        var nodeComponent = Qt.createComponent("Node.qml")
        if(nodeComponent.status !== Component.Ready) {
            console.log(nodeComponent.errorString())
        }
        var node = nodeComponent.createObject(workspace, properties)
        node.parseNode(shaderNode)
        node.dropReceived.connect(function(from, to) {
            var edgesToDelete = []
            for(var i in edges) {
                var edge = edges[i]
                if(edge.to === to) {
                    edgesToDelete.push(edge)
                }
            }
            for(var i in edgesToDelete) {
                edge = edgesToDelete[i]
                deleteEdge(edge)
            }
            createEdge(from, to)
            generate()
        })
        node.handleValueChanged.connect(function() {
            generate()
        })
        nodes.push(node)
        return node
    }

    function indent(text) {
        return new Array(indentLevel * 4 + 1).join(" ") + text
    }

    function addOutput(text) {
        output += indent(text) + "\n"
    }

    function generateHandles(node) {
        var foundHandles = []
        var arrayHandles = {}

        for(var k in node.inputHandles) {
            var handle = node.inputHandles[k]
            if(handle.arrayBased) {
                var found = false
                for(var j in edges) {
                    var edge = edges[j]
                    var fromIdentifier = edge.from.node.identifier
                    if(edge.to === handle) {
                        if(arrayHandles[handle.identifier]) {
                            arrayHandles[handle.identifier].push(fromIdentifier)
                        } else {
                            arrayHandles[handle.identifier] = [fromIdentifier]
                        }
                        found = true
                        break
                    }
                }
                if(!found) {
                    if(handle.value != handle.defaultValue) {
                        var serializedValue = ShaderUtils.serialize(handle.value)
                        if(serializedValue) {
                            if(arrayHandles[handle.identifier]) {
                                arrayHandles[handle.identifier].push(serializedValue)
                            } else {
                                arrayHandles[handle.identifier] = [serializedValue]
                            }
                        }
                    }
                }
            } else {
                var found = false
                for(var j in edges) {
                    var edge = edges[j]
                    if(edge.to === handle) {
                        addOutput(handle.identifier + ": " + edge.from.node.identifier)
                        found = true
                        break
                    }
                }
                if(!found) {
                    if(handle.value != handle.defaultValue) {
                        var serialized = ShaderUtils.serialize(handle.value)
                        if(serialized) {
                            addOutput(handle.identifier + ": " + serialized)
                        }
                    }
                }
            }
        }

        for(var handleName in arrayHandles) {
            var identifiers = arrayHandles[handleName]
            addOutput(handleName + ": [")
            indentLevel += 1
            for(var i in identifiers) {
                addOutput(identifiers[i] + ",")
            }
            indentLevel -= 1
            addOutput("]")
        }
    }

    function generate() {
        if(!finalNode) {
            console.warn("ERROR: Cannot generate tree.")
            console.warn("ERROR: Final node not set!")
            return false
        }

        output = "\n"
        indentLevel = 0

        addOutput("import ShaderNodes 1.0")

        // Generate ids
        var counter = 1
        for(var i in nodes) {
            var node = nodes[i]
            if(node.virtualized) {
                continue
            }
            node.identifier = node.exportedTypeName.toLowerCase() + counter
            counter += 1
        }

        addOutput(finalNode.exportedTypeName + " {")
        indentLevel += 1

//        addOutput("property ShaderBuilder shaderBuilder: parent.shaderBuilder")
        generateHandles(finalNode)

        for(var i in nodes) {
            var node = nodes[i]
            if(node === finalNode) {
                continue
            }

            if(node.virtualized) {
                continue
            }
            addOutput(node.exportedTypeName + " {")
            indentLevel += 1
            addOutput("id: " + node.identifier)
            generateHandles(node)

            indentLevel -= 1
            addOutput("}")
        }

        indentLevel -= 1
        addOutput("}")

        var material = Qt.createQmlObject(output, root, "GeneratedMaterial")
//        material.shaderBuilder = shaderBuilder
        shaderBuilderMaterial.fragmentColor = material

        return true
    }
    
    Flickable {
        id: workspaceFlickable
        
        anchors.fill: parent
        
        contentHeight: workspace.height
        contentWidth: workspace.width
        boundsBehavior: Flickable.DragAndOvershootBounds
        
        ScrollBar.vertical: ScrollBar {}
        ScrollBar.horizontal: ScrollBar {}
        
        Item {
            id: workspace
            
            width: 3840
            height: 2160
        }
    }
}
