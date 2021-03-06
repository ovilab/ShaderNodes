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
    title: qsTr("Simple example")

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

            Entity {
                components: [
                    ShaderBuilderMaterial {
                        id: material
                        surface: StandardSurface {
                            color: "green"
                            normal: Bump {
                                texture: Noise {
                                    vector: material.fragment.position
                                }
                            }
                        }
                    },
                    SphereMesh {
                        id: mesh
                    }
                ]
            }
        }
    }
}
