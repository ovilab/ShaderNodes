import QtQuick 2.0 as QQ2

import ShaderNodes 1.0

ShaderNode {
    id: root

    property var values: [1.0]

    arrayProperties: ["values"]
    exportedTypeName: "Add"

    name: "add"
    type: ShaderNodes.glslType(values)

    source: {
        var result = ""
        result += type + " $sumresult;\n"
        if(values && values.length) {
            for(var i in values) {
                result += "$sumresult += $(values[" + i + "], " + type + ");\n"
            }
        } else {
            result += "$sumresult = $values;\n"
        }

        return result;
    }

    result: "$sumresult"
}
