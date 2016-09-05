import QtQuick 2.5
import SimVis 1.0
import SimVis.ShaderNodes 1.0

ShaderNode {
    property var color: "darkgrey"

    property var ambientColor: color
    property var diffuseColor: color
    property var specularColor: color
    property var ambientIntensity: 1.0
    property var diffuseIntensity: 1.0
    property var specularIntensity: 1.0
    property var hardness: 1.0

    property var normal: ShaderBuilderBinding {
        property: "normal"
        defaultValue: Qt.vector3d(0.0, 0.0, 1.0)
    }
    property var position: ShaderBuilderBinding {
        property: "position"
        defaultValue: Qt.vector3d(0.0, 0.0, 0.0)
    }
    property list<Light> lights

    property list<Light> _defaultLights: [
        Light {
            position: Qt.vector3d(46, 20, -10)
            attenuation: 0.0
            strength: 1.0
        }
    ]

    name: "diffuse"
    type: "vec3"
    source: {
        var output = ""
        output += "$this = vec3(0.0, 0.0, 0.0);\n"
        var lightList = lights
        var lightVariable = "lights"
        if (lightList.length < 1) {
            lightList = _defaultLights
            lightVariable = "_defaultLights"
        }

        for(var i in lightList) {
            output += "$this += standardMaterialLight($" + lightVariable + "[" + i + "], $(normal, vec3), $(position, vec3), eyePosition,\n"
            output += "             $(ambientColor, vec3), $(diffuseColor, vec3), $(specularColor, vec3),\n"
            output += "             0.01 * $(ambientIntensity, float), $(diffuseIntensity, float), 0.01 * $(specularIntensity, float),\n"
            output += "             150.0 * $(hardness, float));\n"
        }
        return output
    }

    headerFile: "qrc:/SimVis/ShaderNodes/shaders/standard_material.glsl"
}
