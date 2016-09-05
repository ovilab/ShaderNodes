import SimVis 1.0

ShaderNode {
    // TODO split light into multiple functions available for different materials (should perhaps be on each material?)

    property var color: "white"
    property var strength: 1.0
    property var position: Qt.vector3d(0.0, 0.0, 0.0)

    property var attenuation: 1.0
    property var gamma: 1.0

    name: "light"
    type: "Light"
    source: "
$this.color = $(color, vec3);
$this.strength = $(strength, float);
$this.position = (vec4($(position, vec3), 1.0)).xyz;
$this.attenuation = $(attenuation, float);
$this.gamma = $(gamma, float);
"

    header: "
struct Light {
    highp vec3 color;
    highp float strength;
    highp vec3 position;
    highp float attenuation;
    highp float gamma;
};

highp float attenuation(Light light, highp vec3 vertexPosition) {
    highp float distanceToLight = distance(vertexPosition, light.position);
    highp float attenuationFactor = 1.0 / (1.0 + light.attenuation * 0.0001 * distanceToLight * distanceToLight);
    return attenuationFactor;
}

highp vec3 gamma(highp vec3 color, highp float gamma) {
    return pow(color, vec3(1.0/gamma));
}
"
}
