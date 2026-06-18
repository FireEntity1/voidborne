shader_type canvas_item;

// Optimized version of the Balatro-style background shader.
// Visual output kept the same, but repeated math and unnecessary work reduced.

uniform highp float spin_rotation_speed = 2.0;
uniform highp float move_speed = 7.0;
uniform highp vec2 offset = vec2(0.0, 0.0);

uniform highp vec4 colour_1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform highp vec4 colour_2 : source_color = vec4(0.02, 0.025, 0.03, 1.0);
uniform highp vec4 colour_3 : source_color = vec4(0.12, 0.11, 0.09, 1.0);

uniform highp float contrast = 3.5;
uniform highp float lighting = 0.2;
uniform highp float spin_amount = 0.0;
uniform highp float pixel_filter = 400.0;
uniform bool is_rotating = true;

#define SPIN_EASE 1.0

void fragment() {
	highp vec2 screen_size = TEXTURE_PIXEL_SIZE;

	// Precompute repeated screen values
	highp float screen_len = length(screen_size);
	highp float inv_screen_len = 1.0 / screen_len;

	// Pixelated UV setup
	highp float pixel_size = screen_len / pixel_filter;
	highp float inv_pixel_size = 1.0 / pixel_size;

	highp vec2 uv = (
		floor(UV * inv_pixel_size) * pixel_size 
		- 0.5 * screen_size
	) * inv_screen_len - offset;

	highp float uv_len = length(uv);

	// Spin
	highp float spin_speed = spin_rotation_speed * 0.2;
	highp float speed = spin_speed;

	if (is_rotating) {
		speed *= TIME;
	}

	speed += 302.2;

	highp float angle = atan(uv.y, uv.x)
		+ speed
		- 20.0 * (spin_amount * uv_len + (1.0 - spin_amount));

	highp vec2 mid = screen_size * inv_screen_len * 0.5;

	uv = vec2(
		uv_len * cos(angle) + mid.x,
		uv_len * sin(angle) + mid.y
	) - mid;

	uv *= 30.0;

	// Movement
	highp float move_time = TIME * move_speed;
	highp float move_time_a = move_time * 0.131121;
	highp float move_time_b = move_time * 0.113;

	highp vec2 uv2 = vec2(uv.x + uv.y);

	// Main pattern loop
	for (int i = 0; i < 5; i++) {
		highp float wave = sin(max(uv.x, uv.y));

		uv2 += wave + uv;

		uv += 0.5 * vec2(
			cos(5.1123314 + 0.353 * uv2.y + move_time_a),
			sin(uv2.x - move_time_b)
		);

		highp float distortion = cos(uv.x + uv.y) - sin(uv.x * 0.711 - uv.y);
		uv -= distortion;
	}

	// Colour calculation
	highp float contrast_mod = 0.25 * contrast + 0.5 * spin_amount + 1.2;
	highp float paint_res = clamp(length(uv) * 0.035 * contrast_mod, 0.0, 2.0);

	highp float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
	highp float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
	highp float c3p = 1.0 - min(1.0, c1p + c2p);

	highp float light_value =
		(lighting - 0.2) * max(c1p * 5.0 - 4.0, 0.0)
		+ lighting * max(c2p * 5.0 - 4.0, 0.0);

	highp float base_mix = 0.3 / contrast;
	highp float colour_mix = 1.0 - base_mix;

	highp vec4 final_col =
		base_mix * colour_1
		+ colour_mix * (
			colour_1 * c1p
			+ colour_2 * c2p
			+ vec4(colour_3.rgb * c3p, colour_1.a * c3p)
		)
		+ vec4(light_value);

	COLOR *= final_col;
}