import QtQuick.Scene3D 2.0

import Qt3D.Core 2.0
import Qt3D.Extras 2.0
import Qt3D.Input 2.0
import Qt3D.Logic 2.0
import Qt3D.Render 2.0

Scene3D {
    id: root

    aspects: ["core", "input", "logic"]

    Entity {
        id: rootEntity

        components: [
            RenderSettings {
                activeFrameGraph: ForwardRenderer {
                    camera: Camera {
                        projectionType: CameraLens.PerspectiveProjection
                        fieldOfView: 50
                        aspectRatio: root.width / root.height
                        nearPlane: 1.0
                        farPlane: 10000.0
                        position: Qt.vector3d(0, 0, 20)
                        viewCenter: Qt.vector3d(0, 0, 0)
                        upVector: Qt.vector3d(0.0, 1.0, 0.0)
                    }
                }
            },
            InputSettings {}
        ]

        Entity {
            components: [
                SphereMesh {},
                PhongMaterial {}
            ]
        }
    }
}
