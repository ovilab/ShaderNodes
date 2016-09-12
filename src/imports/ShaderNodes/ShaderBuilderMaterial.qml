import ShaderNodes 1.0
import ShaderNodes 1.0 as Nodes

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

        shaderType: ShaderBuilder.Fragment
        material: materialRoot

        sourceFile: "qrc:/ShaderNodes/shaders/gl3/shader_builder_material.vert"

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

        // inputs
        property alias position: position
        property alias normal: normal
        property alias tangent: tangent
        property alias binormal: binormal
        property alias textureCoordinate: textureCoordinate

        shaderType: ShaderBuilder.Fragment
        material: materialRoot

        sourceFile: "qrc:/ShaderNodes/shaders/gl3/shader_builder_material.frag"

//        onFinalShaderChanged: console.log(finalShader)

        inputs: [
            ShaderNode {
                // TODO make a BuilderInputNode type
                id: position
                type: "vec3"
                name: "position"
                result: "position"
            },
            ShaderNode {
                id: normal
                type: "vec3"
                name: "normal"
                result: "normal"
            },
            ShaderNode {
                id: tangent
                type: "vec3"
                name: "tangent"
                result: "tangent"
            },
            ShaderNode {
                id: binormal
                type: "vec3"
                name: "binormal"
                result: "binormal"
            },
            ShaderNode {
                id: textureCoordinate
                type: "vec2"
                name: "texCoord"
                result: "texCoord"
            }
        ]
        outputs: [
            ShaderOutput {
                id: _fragmentColor
                type: "vec4"
                name: "fragColor"
                value: Add {}
            }
        ]
    }
}
