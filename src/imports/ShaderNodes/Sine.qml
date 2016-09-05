import SimVis 1.0

ShaderNode {
    property var value

    name: "sine"

    type: glslType(value)
    result: "sin($value)"
}
