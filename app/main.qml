import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("ShaderNodes")

    ListView {
        id: shaderList
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.15

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
            right: parent.horizontalCenter
            bottom: parent.bottom
        }

        shaderBuilderMaterial: previewScene.material
    }

    Rectangle {
        id: shader
        anchors {
            top: parent.top
            left: editor.right
            bottom: parent.bottom
        }
        width: parent.width * 0.25
        clip: true

        Flickable {
            anchors {
                margins: 16
                fill: parent
            }

            contentWidth: shaderText.width
            contentHeight: shaderText.height

            ScrollBar.vertical: ScrollBar {}
            ScrollBar.horizontal: ScrollBar {}

            Text {
                id: shaderText
//                selectByKeyboard: true
//                selectByMouse: true
//                readOnly: true
                text: editor.output //+ "\n" + editor.shaderBuilder.finalShader
            }
        }
    }

    PreviewScene {
        id: previewScene

        anchors {
            right: parent.right
            top: parent.top
            left: shader.right
            bottom: parent.bottom
        }
    }
}
