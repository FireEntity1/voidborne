shader_type canvas_item;

uniform vec4 fog_colour : source_color = vec4(0.45, 0.52, 0.60, 0.22);

uniform float scale = 3.0;
uniform float density = 0.45;
uniform float softness = 0.35;
uniform float alpha_strength = 0.35;

uniform float x_speed = 0.08;
uniform float y_speed = 0.02;

uniform float horizontal_stretch = 3.0;
uniform float vertical_detail = 1.4;

uniform float seed = 12.0;

// Cheap hash.
float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

// Cheap smooth value noise.
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));

	float x1 = mix(a, b, f.x);
	float x2 = mix(c, d, f.x);

	return mix(x1, x2, f.y);
}

void fragment() {
	vec2 uv = UV;

	// Correct aspect so the noise does not get stretched weirdly.
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	uv.x *= aspect;

	// Stretch the fog horizontally.
	// Dividing x makes long horizontal shapes instead of vertical bands.
	vec2 fog_uv = vec2(
		uv.x / max(horizontal_stretch, 0.001),
		uv.y * vertical_detail
	);

	// Movement.
	fog_uv += vec2(x_speed, y_speed) * TIME;

	// Random layered noise.
	float n = 0.0;

	n += noise(fog_uv * scale + seed) * 0.55;
	n += noise(fog_uv * scale * 2.1 + seed * 2.7) * 0.30;
	n += noise(fog_uv * scale * 4.3 + seed * 5.1) * 0.15;

	// Shape into soft fog patches.
	float fog = smoothstep(density, density + softness, n);

	vec4 col = fog_colour;
	col.a *= fog * alpha_strength;

	COLOR = col;
}