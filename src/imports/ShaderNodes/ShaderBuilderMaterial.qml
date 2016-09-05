import SimVis 1.0
import SimVis.ShaderNodes 1.0
import SimVis.ShaderNodes 1.0 as Nodes

import Qt3D.Core 2.0
import Qt3D.Render 2.0

import QtQuick 2.0 as QQ2
import QtQuick.Scene3D 2.0

Material {
    id: materialRoot

    property alias fragmentColor: _fragmentColor.value
    property alias vertexPosition: _position.value

    property alias vertex: vertexShaderBuilder
    property alias fragment: shaderBuilder

    effect: Effect {
        techniques: Technique {
            filterKeys: [
                FilterKey {
                    id: forward
                    name: "renderingStyle"
                    value: "forward"
                }
            ]
            renderPasses: RenderPass {
                shaderProgram: ShaderProgram {
                    vertexShaderCode: vertexShaderBuilder.finalShader
                    fragmentShaderCode: shaderBuilder.finalShader
                }
            }
        }
    }
    ShaderBuilder {
        id: vertexShaderBuilder

        shaderType: ShaderBuilder.Fragment
        material: materialRoot

        // inputs
        property ShaderNode position: ShaderNode {
            type: "vec3"
            name: "position"
            result: "position"
        }
        property ShaderNode normal: ShaderNode {
            type: "vec3"
            name: "vertexNormal"
            result: "vertexNormal"
        }
        property ShaderNode textureCoordinate: ShaderNode {
            type: "vec2"
            name: "vertexTexCoord"
            result: "vertexTexCoord"
        }

        sourceFile: "qrc:/SimVis/ShaderNodes/shaders/gl3/shader_builder_material.vert"

//        onFinalShaderChanged: console.log(finalShader)

        outputs: [
            ShaderOutput {
                id: _position
                type: "vec3"
                name: "position"
                value: vertexShaderBuilder.position
            }
        ]
    }
    ShaderBuilder {
        id: shaderBuilder

        shaderType: ShaderBuilder.Fragment
        material: materialRoot

        // inputs
        property ShaderNode position: ShaderNode {
            type: "vec3"
            name: "position"
            result: "position"
        }
        property ShaderNode normal: ShaderNode {
            type: "vec3"
            name: "normal"
            result: "normal"
        }
        property ShaderNode tangent: ShaderNode {
            type: "vec3"
            name: "tangent"
            result: "tangent"
        }
        property ShaderNode binormal: ShaderNode {
            type: "vec3"
            name: "binormal"
            result: "binormal"
        }
        property ShaderNode textureCoordinate: ShaderNode {
            type: "vec2"
            name: "texCoord"
            result: "texCoord"
        }

//        onFinalShaderChanged: console.log(finalShader)

        sourceFile: "qrc:/SimVis/ShaderNodes/shaders/gl3/shader_builder_material.frag"

        outputs: [
            ShaderOutput {
                id: _fragmentColor
                type: "vec4"
                name: "fragColor"
                value: StandardMaterial {}
            }
        ]
    }
}
