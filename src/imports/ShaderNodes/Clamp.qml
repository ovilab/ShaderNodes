import SimVis 1.0

ShaderNode {
    property var value
    property var minimumValue
    property var maximumValue

    name: "clamp"
    type: glslType(value)
    result: "clamp($value, $(minimumValue, float), $(maximumValue, float))"
}
