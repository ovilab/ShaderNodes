import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 1080
    title: qsTr("ShaderNodes")

    Settings {
        id: settings
        property alias windowWidth: root.width
        property alias windowHeight: root.height
    }

    ListView {
        id: shaderList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.10
        model: ListModel {
            ListElement {name: "Add"}
            ListElement {name: "AmbientOcclusion"}
            ListElement {name: "Bump"}
            ListElement {name: "Clamp"}
            ListElement {name: "CombineRgb"}
            ListElement {name: "Decolorize"}
            ListElement {name: "Displacement"}
//            ListElement {name: "Function"}
//            ListElement {name: "Geometry"}
            ListElement {name: "ImageTexture"}
            ListElement {name: "Light"}
            ListElement {name: "Mix"}
            ListElement {name: "Multiply"}
            ListElement {name: "Noise"}
            ListElement {name: "NormalMap"}
            ListElement {name: "Simplex"}
            ListElement {name: "Sine"}
//            ListElement {name: "Split"}
            ListElement {name: "StandardMaterial"}
            ListElement {name: "Subtract"}
            ListElement {name: "Sum"}
        }

        delegate: ItemDelegate {
            text: name
            Loader {
                id: node
                source: "qrc:/ShaderNodes/" + name + ".qml"
            }

            onClicked: {
                editor.createNode(node.item, {x: 200, y: 200})
            }
        }
    }

    Editor {
        id: editor

        anchors {
            left: shaderList.right
            top: parent.top
            bottom: parent.bottom
        }

        width: parent.width * 0.6

        shaderBuilderMaterial: previewScene.material
    }

    Pane {
        id: propertiesPane
        anchors {
            top: parent.top
            bottom: parent.verticalCenter
            right: parent.right
            left: editor.right
        }

        Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            Repeater {
                model: editor.activeNode ? editor.activeNode.handles : undefined
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    width: 120
                    height: 80
                    Text {
                        anchors.centerIn: parent
                        text: model.name
                    }
                }
            }
        }
    }

//    Pane {
//        id: shader
//        anchors {
//            top: parent.top
//            left: editor.right
//            bottom: parent.verticalCenter
//            right: parent.right
//        }
//        clip: true

//        Flickable {
//            anchors {
//                margins: 16
//                fill: parent
//            }

//            contentWidth: shaderText.width
//            contentHeight: shaderText.height

//            ScrollBar.vertical: ScrollBar {}
//            ScrollBar.horizontal: ScrollBar {}

//            Label {
//                id: shaderText
////                selectByKeyboard: true
////                selectByMouse: true
////                readOnly: true
//                text: editor.output //+ "\n" + editor.shaderBuilder.finalShader
//            }
//        }
//    }

    PreviewScene {
        id: previewScene

        anchors {
            right: parent.right
            top: parent.verticalCenter
            left: editor.right
            bottom: parent.bottom
        }
    }
}
