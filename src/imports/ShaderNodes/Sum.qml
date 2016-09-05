import SimVis 1.0

ShaderNode {
    property list<ShaderNode> inputs

    type: "float"
    source: {
        var output = "";
        output += "float $sumresult = 0.0;\n"
        for(var i in inputs) {
            output += "$sumresult += $(inputs[" + i + "], float);\n";
        }
        return output
    }
    result: "$sumresult"
}
