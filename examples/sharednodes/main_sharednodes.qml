import QtQuick 2.7
import QtQuick.Controls 1.0 as QQC1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import QtQuick.Scene3D 2.0

import Qt3D.Core 2.0
import Qt3D.Extras 2.0
import Qt3D.Input 2.0
import Qt3D.Logic 2.0
import Qt3D.Render 2.0

import ShaderNodes 1.0

ApplicationWindow {
    id: window

    visible: true
    width: 1280
    height: 1024
    title: qsTr("Shared materials")

    Scene3D {
        id: root

        anchors.fill: parent

        aspects: ["logic", "input"]
        Entity {
            components: [
                RenderSettings{
                    activeFrameGraph: ForwardRenderer {
                        camera: Camera {
                            id: mainCamera
                            projectionType: CameraLens.PerspectiveProjection
                            fieldOfView: 50
                            aspectRatio: root.width / root.height
                            nearPlane: 1.0
                            farPlane: 100.0
                            position: Qt.vector3d(8, 4, 8)
                            viewCenter: Qt.vector3d(0, 0, 0)
                            upVector: Qt.vector3d(0.0, 1.0, 0.0)
                        }
                        clearColor: Qt.rgba(0.2, 0.2, 0.2)
                    }
                },
                InputSettings {}
            ]

            OrbitCameraController {
                camera: mainCamera
            }

//            Entity {
//                components: [
//                    mesh,
//                    transform1,
//                    material1
//                ]

//                Transform {
//                    id: transform1
//                    translation: Qt.vector3d(-4, 0, 0)
//                }
//            }
            Entity {
                components: [
                    mesh,
                    transform2,
                    material2
                ]

                Transform {
                    id: transform2
                    translation: Qt.vector3d(4, 0, 0)
                }
            }

            Light {
                id: light1
                position: Qt.vector3d(0, slider.value * 8, -4)
            }

            Light {
                id: light2
                position: Qt.vector3d(0, 4, 4)
            }

//            ShaderBuilderMaterial {
//                id: material1

//                fragmentColor: StandardMaterial {
//                    color: "green"
//                    lights: [
//                        light1,
//                        light2
//                    ]
//                }
//            }

            ShaderBuilderMaterial {
                id: material2

//                fragmentColor: StandardMaterial {
//                    id: standardMaterial2
//                    color: "green"
//                    lights: [
//                        light1,
//                        light2
//                    ]
//                }

                fragmentColor: Mix {
                    id: standardMaterial2
                    value1: 1.0
                    value2: Qt.vector3d(0.1, 0.1, 0.1)
                }
            }

            SphereMesh {id: mesh}
        }
    }

    Column {
        QQC1.Slider {
            id: slider
            minimumValue: 0.0
            maximumValue: 1.0
            value: 0.5
            width: 300
        }

        Timer {
            property ShaderNode node: null
            running: true
            repeat: true
            interval: 60
            onTriggered: {
                if(node) {
                    standardMaterial2.value1 = 2.3
                    standardMaterial2.value1 = Qt.vector3d(2.0, 1.0, 2.0)
                    node.destroy()
                    node = null
                } else {
                    var object = Qt.createQmlObject("import ShaderNodes 1.0; Mix {}", material2)
                    standardMaterial2.value1 = object
                    node = object
                }
            }
        }

//        Timer {
//            running: true
//            repeat: true
//            interval: 100
//            onTriggered: {
//                standardMaterial2.value1 = 1.0
//            }
//        }

//        Timer {
//            running: true
//            repeat: true
//            interval: 150
//            onTriggered: {
//                standardMaterial2.value1 = node
//            }
//        }

//        Timer {
//            running: true
//            repeat: true
//            interval: 180
//            onTriggered: {
//                standardMaterial2.value1 = Qt.vector3d(1.0, 0.5, 0.1)
//            }
//        }
    }
}
