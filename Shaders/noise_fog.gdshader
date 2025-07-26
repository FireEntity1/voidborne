shader_type canvas_item;

uniform float fog_density : hint_range(0.1, 1.0) = 0.5; // Controls the density of the fog
uniform float fog_speed : hint_range(0.1, 2.0) = 0.3;   // Controls the movement speed
uniform float noise_scale : hint_range(1.0, 10.0) = 4.0; // Scale of the noise pattern
uniform float fog_opacity : hint_range(0.1, 1.0) = 0.5; // Opacity of the fog

// Classic Perlin noise function
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV * noise_scale;

    // Animate the fog with time
    uv += vec2(TIME * fog_speed * 0.1, TIME * fog_speed * 0.05);

    // Sample the noise
    float n = noise(uv);

    // Apply fog density and opacity
    float fog = smoothstep(1.0 - fog_density, 1.0, n);
    fog *= fog_opacity;

    // Output color with transparency
    COLOR = vec4(vec3(0.5), fog); // Gray fog (0.5 for gray)
}
