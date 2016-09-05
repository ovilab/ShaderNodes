import SimVis 1.0

ShaderNode {
    property var value1
    property var value2
    property var mix: 0.5

    name: "mix"
    type: preferredType(value1, value2)
    result: "$(value1, " + type + ") * (1.0 - $(mix, float)) + $(value2, " + type + ") * $(mix, float)"
}
