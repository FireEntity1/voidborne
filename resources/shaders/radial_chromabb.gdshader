shader_type canvas_item;

uniform float intensity: hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float threshold: hint_range(0.0, 2.0, 0.1) = 0.4;
uniform float spread: hint_range(0.0, 10.0, 0.1) = 2.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 dir = SCREEN_UV - center;

	float dist = length(dir) * 2.0;

	vec2 radial = vec2(0.0);
	if (dist > 0.0001) {
		radial = normalize(dir);
	}

	float effect = max(dist - threshold, 0.0);
	float amount = effect * effect * intensity * spread;

	vec2 offset = radial * amount * SCREEN_PIXEL_SIZE;

	vec2 r_uv = clamp(SCREEN_UV - offset, vec2(0.0), vec2(1.0));
	vec2 g_uv = SCREEN_UV;
	vec2 b_uv = clamp(SCREEN_UV + offset, vec2(0.0), vec2(1.0));

	float r = textureLod(screen_texture, r_uv, 0.0).r;
	float g = textureLod(screen_texture, g_uv, 0.0).g;
	float b = textureLod(screen_texture, b_uv, 0.0).b;
	float a = textureLod(screen_texture, SCREEN_UV, 0.0).a;

	COLOR = vec4(r, g, b, a);
}