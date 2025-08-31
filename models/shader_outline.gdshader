shader_type spatial;

uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float line_thickness = 2;

varying vec3 barycentric;

void vertex() {
    // Assign barycentric coordinates per vertex
    if (VERTEX_ID % 3 == 0) {
        barycentric = vec3(1.0, 0.0, 0.0);
    } else if (VERTEX_ID % 3 == 1) {
        barycentric = vec3(0.0, 1.0, 0.0);
    } else {
        barycentric = vec3(0.0, 0.0, 1.0);
    }
}

void fragment() {
    float edge = min(min(barycentric.x, barycentric.y), barycentric.z);
    float wire = smoothstep(0.0, line_thickness, edge);
    ALBEDO = mix(line_color.rgb, ALBEDO, wire);
}