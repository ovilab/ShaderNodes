import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.0 as QtControls

import ShaderNodes 1.0

Pane {
    id: root

    property Editor editor
    
    Column {
        anchors {
            left: parent.left
            right: parent.right
        }
        
        Label {
            text: editor.activeNode ? editor.activeNode.title : ""
        }
        
        Repeater {
            model: editor.activeNode ? editor.activeNode.inputHandles : undefined
            
            Item {
                property Handle handle: modelData
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: loader.height
                
                Component {
                    id: floatEditComponent
                    Item {
                        height: textField.height
                        Label {
                            anchors {
                                left: parent.left
                                right: textField.left
                                verticalCenter: parent.verticalCenter
                            }
                            wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                            text: handle.name
                        }
                        TextField {
                            id: textField
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            text: handle.value
                            inputMethodHints: Qt.ImhPreferNumbers
                            onEditingFinished: {
                                handle.value = parseFloat(textField.text)
                            }
                        }
                    }
                }
                
                Component {
                    id: occupiedComponent
                    Label {
                        text: handle.name + ": node"
                    }
                }

                Component {
                    id: unknownComponent
                    Label {
                        text: handle.name + ": default"
                    }
                }

                Component {
                    id: colorComponent
                    Item {
                        id: colorPicker

                        property real hue: 0.5
                        property real saturation: 0.5
                        property real value: 0.5
                        property color color: handle.value

                        function updateHandleValue() {
                            handle.value = ShaderUtils.hsv(hue, saturation, value)
                        }

                        onColorChanged: {
                            hue = ShaderUtils.hsvHue(color)
                            saturation = ShaderUtils.hsvSaturation(color)
                            value = ShaderUtils.hsvValue(color)
                        }

                        height: label.height + 12

                        Label {
                            id: label
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            text: handle.name + ":"
                        }

                        Rectangle {
                            id: colorRect

                            anchors {
                                right: parent.right
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width: 64
                            color: colorPicker.color
                            radius: 16
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    popup.open()
                                }
                            }
                        }
                        Popup {
                            id: popup

                            x: colorRect.x + colorRect.width - width
                            y: colorRect.y + colorRect.height

                            width: 300
                            height: 400
//                            modal: true
                            focus: true
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent


                            Column {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                }

                                Item {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                    }
                                    height: circlePicker.height

                                    Image {
                                        id: circlePicker
                                        anchors {
                                            left: parent.left
                                            margins: 8
                                        }
                                        height: width
                                        width: parent.width * 0.85

                                        smooth: true
                                        antialiasing: true
                                        mipmap: true

                                        source: "images/colorwheel.png"

                                        Rectangle {
                                            anchors {
                                                fill: parent
                                                margins: -2
                                            }
                                            color: "black"
                                            opacity: 1.0 - colorPicker.value
                                            radius: width * 0.5
                                        }

                                        Rectangle {
                                            id: circlePickerHandle

                                            x: circlePicker.width * 0.5 + circlePicker.width * 0.5 * colorPicker.saturation * Math.cos(colorPicker.hue * 2 * Math.PI) - width / 2
                                            y: circlePicker.width * 0.5 + circlePicker.width * 0.5 *colorPicker.saturation * Math.sin(colorPicker.hue * 2 * Math.PI) - height / 2
                                            width: 8
                                            height: 8
                                            radius: width * 0.5
                                            border.color: "black"
                                            border.width: 2.0
                                            color: "white"
                                        }

                                        MouseArea {
                                            anchors.fill: parent

                                            function movePicker(mouse) {
                                                var radius = width / 2
                                                var x = (mouse.x - radius) / radius
                                                var y = (mouse.y - radius) / radius

                                                var r = Math.sqrt(x*x + y*y)
                                                var phi = Math.atan2(y, x)

                                                if(phi < 0) {
                                                    phi += 2.0 * Math.PI
                                                }

                                                colorPicker.hue = Math.max(0.0, Math.min(1.0, phi / (2 * Math.PI)))
                                                colorPicker.saturation = Math.max(0.0, Math.min(1.0, r))

                                                updateHandleValue()
                                            }

                                            onPressed: movePicker(mouse)
                                            onPositionChanged: movePicker(mouse)
                                        }
                                    }

                                    LinearGradient {
                                        id: linearPicker
                                        anchors {
                                            top: parent.top
                                            bottom: parent.bottom
                                            left: circlePicker.right
                                            right: parent.right
                                            margins: 8
                                        }

                                        start: Qt.point(0, 0)
                                        end: Qt.point(0, height)

                                        gradient: Gradient {
                                            GradientStop {position: 0; color: "white"}
                                            GradientStop {position: 1.0; color: "black"}
                                        }

                                        Rectangle {
                                            id: linearPickerHandle
                                            anchors {
                                                horizontalCenter: parent.horizontalCenter
                                            }

                                            y: linearPicker.height * (1.0 - colorPicker.value) - width / 2

                                            width: 8
                                            height: 8
                                            radius: width * 0.5
                                            border.color: "black"
                                            border.width: 2.0
                                            color: "white"

                                        }

                                        MouseArea {
                                            anchors.fill: parent

                                            function movePicker(mouse) {
                                                var lightness = (height - mouse.y) / height
                                                colorPicker.value = Math.max(0.0, Math.min(1.0, lightness))

                                                updateHandleValue()
                                            }

                                            onPressed: movePicker(mouse)
                                            onPositionChanged: movePicker(mouse)
                                        }
                                    }
                                }

                                Column {
                                    id: rgbColumn
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        margins: 8
                                    }

                                    Label {
                                        text: "R:"
                                    }
                                    Label {
                                        text: "G:"
                                    }
                                    Label {
                                        text: "B:"
                                    }
                                    Label {
                                        text: "A:"
                                    }
                                }
                            }
                        }
                    }
                }
                
                Loader {
                    id: loader
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    
                    sourceComponent: {
                        if(handle.occupied) {
                            return occupiedComponent
                        }
                        switch(ShaderUtils.variantType(handle.defaultValue)) {
                        case ShaderUtils.Int:
                        case ShaderUtils.Float:
                            return floatEditComponent
                        case ShaderUtils.Color:
                        case ShaderUtils.String:
                            return colorComponent
                        default:
                            return unknownComponent
                        }
                    }
                }
            }
        }
    }
}
