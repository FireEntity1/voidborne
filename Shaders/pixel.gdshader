shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size : hint_range(1, 64) = 4; // Pixel size
uniform vec2 screen_size = vec2(1920.0, 1080.0); // Screen size (set manually)

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 pixel_coords = uv * screen_size;

    vec2 quantized_coords = floor(pixel_coords / float(pixel_size)) * float(pixel_size);

    quantized_coords += float(pixel_size) * 0.5;

    vec2 final_uv = quantized_coords / screen_size;

    COLOR = texture(SCREEN_TEXTURE, final_uv);
}