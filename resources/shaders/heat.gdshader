shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float strength_pixels : hint_range(0.0, 8.0, 0.1) = 1.25;
uniform float wave_scale : hint_range(1.0, 30.0, 0.5) = 10.0;
uniform float wave_speed : hint_range(0.0, 10.0, 0.1) = 1.4;
uniform float vertical_distortion : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float effect_opacity : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform float edge_softness : hint_range(0.01, 0.5, 0.01) = 0.15;

void fragment() {
	float time = TIME * wave_speed;

	// Two overlapping waves stop the effect from looking too uniform.
	float wave_1 = sin(UV.y * wave_scale * TAU + time);
	float wave_2 = sin(
		UV.y * wave_scale * 1.73 * TAU
		- time * 1.31
		+ UV.x * 4.0
	);

	float combined_wave = wave_1 * 0.65 + wave_2 * 0.35;

	// Mostly horizontal distortion, with a tiny vertical shimmer.
	vec2 distortion = vec2(
		combined_wave,
		cos(UV.x * wave_scale * TAU - time) * vertical_distortion
	);

	distortion *= strength_pixels * SCREEN_PIXEL_SIZE;

	// Fade the effect near the rectangle's edges.
	float edge_mask =
		smoothstep(0.0, edge_softness, UV.x) *
		smoothstep(0.0, edge_softness, 1.0 - UV.x) *
		smoothstep(0.0, edge_softness, UV.y) *
		smoothstep(0.0, edge_softness, 1.0 - UV.y);

	// Sprite textures can act as custom-shaped masks.
	float texture_mask = texture(TEXTURE, UV).a;
	float mask = edge_mask * texture_mask * effect_opacity;

	vec4 original_color = texture(screen_texture, SCREEN_UV);
	vec4 distorted_color = texture(
		screen_texture,
		clamp(
			SCREEN_UV + distortion,
			SCREEN_PIXEL_SIZE,
			vec2(1.0) - SCREEN_PIXEL_SIZE
		)
	);

	COLOR = mix(original_color, distorted_color, mask);
}