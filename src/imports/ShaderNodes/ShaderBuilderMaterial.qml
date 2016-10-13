import ShaderNodes 1.0
import ShaderNodes 1.0 as Nodes

import Qt3D.Core 2.0
import Qt3D.Render 2.0

import QtQuick 2.0 as QQ2
import QtQuick.Scene3D 2.0

Material {
    property alias fragmentColor: shaderBuilderEffect.fragmentColor
    property alias vertexPosition: shaderBuilderEffect.vertexPosition

    property alias vertex: shaderBuilderEffect.vertexShaderBuilder
    property alias fragment: shaderBuilderEffect.fragmentShaderBuilder

    effect: ShaderBuilderEffect {
        id: shaderBuilderEffect
    }

    // TODO add ParameterBinding
}
