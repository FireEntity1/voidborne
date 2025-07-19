// A Customizable Gausian Blur Shader
// Credits to DJBob Gaming YT :D
shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int blur_radius : hint_range(1, 32) = 8;
uniform float Darkness : hint_range(0.0,1.0) = 0.1;
uniform float R : hint_range(0.0,1.0) = 0;
uniform float G : hint_range(0.0,1.0) = 0;
uniform float B : hint_range(0.0,1.0) = 0;
uniform float blur_strength : hint_range(0.1, 10.0) = 1.0;

float gaussian_weight(float i, float sigma) {
    return exp(-0.5 * (i * i) / (sigma * sigma));
}

void calculate_kernel(out float kernel[32], int radius, float sigma) {
    float sum = 0.0;
    for (int i = 0; i <= radius; i++) {
        kernel[i] = gaussian_weight(float(i), sigma);
        sum += i == 0 ? kernel[i] : 2.0 * kernel[i];
    }
    for (int i = 0; i <= radius; i++) {
        kernel[i] /= sum;
    }
}

void fragment() {
    vec2 resolution = SCREEN_PIXEL_SIZE;
    vec2 uv = SCREEN_UV;

    float kernel[32];
    calculate_kernel(kernel, blur_radius, blur_strength);

    vec3 final_color = vec3(0.0);
    float total_weight = 0.0;

    for (int x = -blur_radius; x <= blur_radius; x++) {
        for (int y = -blur_radius; y <= blur_radius; y++) {
            float weight = kernel[abs(x)] * kernel[abs(y)];
            vec2 offset = vec2(float(x), float(y)) * resolution;
            final_color += texture(SCREEN_TEXTURE, uv + offset).rgb * weight;
            total_weight += weight;
        }
    }

    final_color /= total_weight;
	final_color.r = (final_color.r + R) - Darkness;
	final_color.g = (final_color.g + G) - Darkness;
	final_color.b = (final_color.b + B) - Darkness;

    COLOR = vec4(final_color, 1.0);
}