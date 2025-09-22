shader_type canvas_item;

uniform vec2 viewport_size;
uniform vec2 mouse_pos;
uniform float time;

void fragment() {
	vec2 uv = UV;
	vec2 screen_uv = uv * viewport_size;
	vec2 mouse_uv = mouse_pos;

	// Calculate distance from mouse
	float dist = distance(screen_uv, mouse_uv);

	// Use smoothstep to make a soft blend mask
	float radius = 100.0;  // radius of glitch effect in pixels
	float softness = 40.0; // how soft the edge is
	float glitch_strength = smoothstep(radius, radius - softness, dist);

	// Glitch offset (you can customize this part)
	vec2 offset_uv = uv;
	offset_uv.x += sin(time * 10.0 + uv.y * 80.0) * 0.02 * glitch_strength;

	// Final color
	vec4 glitched_color = texture(TEXTURE, offset_uv);
	vec4 original_color = texture(TEXTURE, uv);
	COLOR = mix(original_color, glitched_color, glitch_strength);
}