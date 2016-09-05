import SimVis 1.0

ShaderNode {
    property var value1: 0.0
    property var value2: 0.0

    name: "subtract"
    type: glslType(value1)
    result: "$value1 - $(value2, " + type + ")"
}
