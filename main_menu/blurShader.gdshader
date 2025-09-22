shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap; // Required in Godot 4
uniform float blur_amount : hint_range(0.0, 10.0) = 5.0;

void fragment() {
    vec2 size = vec2(1.0) / vec2(textureSize(SCREEN_TEXTURE, 0)); // Get pixel size
    vec4 sum = vec4(0.0);
    float total = 0.0;

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y));
            float weight = 1.0 - length(offset) / 3.0;
            sum += texture(SCREEN_TEXTURE, UV + offset * size * blur_amount) * weight;
            total += weight;
        }
    }

    COLOR = sum / total;
}