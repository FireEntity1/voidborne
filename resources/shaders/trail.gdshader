shader_type canvas_item;

uniform float length : hint_range(0.0, 64.0, 1.0) = 8.0;
uniform vec2 velocity = vec2(0.0, 0.0);

const int MAX_TRAIL_LENGTH = 64;
const float MIN_VELOCITY = 1.0;
const float ALPHA_START = 0.75;
const float ALPHA_END = 0.03;
const float MIN_SOURCE_ALPHA = 0.05;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 pixel_snap_uv(vec2 uv, vec2 pixel_size) {
	return (floor(uv / pixel_size) + 0.5) * pixel_size;
}

void fragment() {
	vec2 pixel_uv = pixel_snap_uv(UV, TEXTURE_PIXEL_SIZE);

	vec4 base_col = texture(TEXTURE, pixel_uv);
	COLOR = base_col;

	float vel_len_sq = velocity.x * velocity.x + velocity.y * velocity.y;

	if (base_col.a <= 0.0 && vel_len_sq >= MIN_VELOCITY * MIN_VELOCITY) {
		vec2 dir = normalize(velocity);

		int steps = int(clamp(length, 0.0, float(MAX_TRAIL_LENGTH)));
		bool found_trail_pixel = false;

		for (int i = 1; i <= MAX_TRAIL_LENGTH; i++) {
			if (i > steps || found_trail_pixel) {
				break;
			}

			float dist = float(i);
			float t = dist / max(length, 1.0);

			vec2 sample_uv = pixel_uv + dir * TEXTURE_PIXEL_SIZE * dist;

			if (
				sample_uv.x >= 0.0 && sample_uv.x <= 1.0 &&
				sample_uv.y >= 0.0 && sample_uv.y <= 1.0
			) {
				vec4 src_col = texture(TEXTURE, sample_uv);

				if (src_col.a > MIN_SOURCE_ALPHA) {
					vec2 pixel_id = floor(pixel_uv / TEXTURE_PIXEL_SIZE);

					float keep_chance = mix(0.95, 0.18, t);
					float noise = hash(pixel_id + vec2(float(i) * 11.7, floor(TIME * 12.0)));

					if (noise <= keep_chance) {
						float alpha = mix(ALPHA_START, ALPHA_END, t);
						vec3 trail_rgb = mix(src_col.rgb, src_col.rgb * 0.4, t);

						COLOR = vec4(trail_rgb, src_col.a * alpha);
						found_trail_pixel = true;
					}
				}
			}
		}
	}
}