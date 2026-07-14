shader_type canvas_item;

// Uniforms for customization
uniform sampler2D noise_texture : repeat_enable;
uniform vec3 smoke_color : source_color = vec3(0.8);
uniform float distortion_speed : hint_range(0.0, 5.0) = 0.2;
uniform float density : hint_range(0.0, 1.0) = 1.0;
uniform float pixelization : hint_range(1.0, 512.0) = 128.0;

void fragment() {
    // Pre-calculate time-based offsets
    float time_offset_1 = TIME * distortion_speed * 0.1;
    float time_offset_2 = TIME * distortion_speed * 0.2;
    
    vec2 pixelated_uv = floor(UV * pixelization) / pixelization;
    
    // Sample noise with distortion
    vec4 noise = texture(noise_texture, pixelated_uv + time_offset_1);
    
    // Create distorted UV and sample final noise
    vec2 distorted_uv = pixelated_uv + noise.rg * 0.1 - 0.05 + time_offset_2;
    float final_noise = texture(noise_texture, distorted_uv).r;
    
    float smoke_alpha = final_noise * density;
    
    // Output color
    COLOR = vec4(smoke_color, smoke_alpha);
}