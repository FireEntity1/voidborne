shader_type canvas_item;

uniform float speed_pixels_per_second = 16.0;
uniform float offset_pixels = 0.0;

varying vec4 vertex_modulate;

void vertex() {
	vertex_modulate = COLOR;
}

void fragment() {
	ivec2 tex_size = textureSize(TEXTURE, 0);

	ivec2 pixel = ivec2(floor(UV * vec2(tex_size)));
	pixel = clamp(pixel, ivec2(0), tex_size - ivec2(1));

	int scroll = int(floor(TIME * speed_pixels_per_second + offset_pixels));

	pixel.y = int(mod(float(pixel.y - scroll), float(tex_size.y)));

	COLOR = texelFetch(TEXTURE, pixel, 0) * vertex_modulate;
}