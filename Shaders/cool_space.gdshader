shader_type canvas_item;

// --- Star and Time Configuration ---
uniform bool stars_on = true;             // Toggle star rendering
uniform bool stars_flicker = true;        // Toggle flickering effect for stars
uniform float timeScaleFactor = 0.04;     // Time scaling for animation speed

// --- Noise Texture for Clouds and Flow ---
uniform sampler2D noise_texture : repeat_enable, filter_linear;

// --- Color Control ---
uniform vec4 colour_muiltiplier : source_color = vec4(1.0); // Final color tint
uniform vec4 colour_muiltiplier2 : source_color = vec4(1.0); // Extra post-multiplier

// --- Visual Tuning Parameters ---
uniform float brightness : hint_range(0.0, 3.0) = 1.2;
uniform float clouds_resolution : hint_range(0.0, 20.0) = 10.0;
uniform float clouds_intesity : hint_range(-0.06, 0.5) = 0.0;
uniform float waveyness : hint_range(0.0, 10.0) = 0.5;
uniform float fragmentation : hint_range(0.0, 100.0) = 7.0;
uniform float distortion : hint_range(0.0, 10.0) = 1.5;
uniform float clouds_alpha : hint_range(0.4, 0.6) = 0.5;
uniform float movement : hint_range(0.7, 2.0) = 1.3;
uniform float blur : hint_range(0.0, 10.0) = 1.4;
uniform float blur2 : hint_range(0.0, 0.01) = 0.01;

// --- Parallax Speeds for Depth Layers ---
uniform float bg_speed = 0.1;
uniform float mid_speed = 0.5;
uniform float fg_speed = 1.0;

// Scaled time for animation
float localTime() {
    return TIME * timeScaleFactor;
}

// 2D rotation matrix
mat2 makem2(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(vec2(c, -s), vec2(s, c));
}

// Noise sampling from red channel
float noise(vec2 x) {
    return texture(noise_texture, x * blur2).x;
}

// Noise sampling from green channel
float noisey(vec2 y) {
    return texture(noise_texture, y * blur2).y;
}

// Gradient noise for flow field
vec2 gradn(vec2 p) {
    float ep = 0.09;
    float gradx = noise(vec2(p.x + ep, p.y)) - noise(vec2(p.x - ep, p.y));
    float grady = noisey(vec2(p.x, p.y + ep)) - noisey(vec2(p.x, p.y - ep));
    return vec2(gradx, grady);
}

// Main procedural cloud flow calculation
float flow(vec2 p) {
    float z = 2.0;
    float rz = clouds_intesity;
    vec2 bp = p;

    for (float i = 1.0; i < 7.0; ++i) {
        p += localTime() * 0.6;
        bp += localTime() * 5.9;
        vec2 gr = gradn(i * p * 0.34 + localTime());
        gr *= makem2(localTime() * 6.0 - (.05 * p.x + .03 * p.y) * 90.0); // Rotate gradients
        p += gr * waveyness;
        rz += (sin(noise(p) * fragmentation) * distortion + clouds_alpha) / z;
        p = mix(bp, p, movement); // Mix distorted and original path
        z *= blur;
        p *= 2.0;
        bp *= 1.9;
    }
    return rz;
}

// Pseudorandom star generation
float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Scale and tile UV coordinates
    vec2 p = UV * clouds_resolution;
    p *= clouds_resolution;

    // Parallax layer offsets
    vec2 bg_p = p * bg_speed;
    vec2 mid_p = p * mid_speed;
    vec2 fg_p = p * fg_speed;

    // Base colors for clouds (can be modified)
    float red = 0.2 * sin(TIME * 0.1);
    float blue = 0.1;
    float green = 0.1;

    // Flow calculations for each depth layer
    float bg_rz = flow(bg_p);
    float mid_rz = flow(mid_p);
    float fg_rz = flow(fg_p);

    // Color composition from each layer
    vec3 col_bg = vec3(red, blue, green) / bg_rz;
    vec3 col_mid = vec3(red, blue, green) / mid_rz;
    vec3 col_fg = vec3(red, blue, green) / fg_rz;

    // Brightness adjustment
    col_bg = pow(col_bg, vec3(brightness));
    col_mid = pow(col_mid, vec3(brightness));
    col_fg = pow(col_fg, vec3(brightness));

    // --- Star field generation ---
    float stars = 0.0;
    vec2 star_uv = UV * 100.0 + localTime() * bg_speed * 20.0; // Move stars slowly
    vec2 grid_pos = floor(star_uv);     // Cell ID
    vec2 local_pos = fract(star_uv);    // Position within cell

    float rand_val = rand(grid_pos);
    if (rand_val > 0.965) {
        float dist = distance(local_pos, vec2(0.5)); // Centered fade
        float intensity = smoothstep(0.05, 0.0, dist);
        float flicker = stars_flicker ? (0.5 + 0.5 * sin(TIME * (rand_val * 3.0) + rand_val * 100.0)) : 1.0;
        stars = intensity * flicker * rand_val;
    }

    // Final composite color from all layers
    vec3 final_col = col_bg + col_mid + col_fg;

    // Add stars on top if enabled
    if (stars_on) {
        final_col += vec3(stars);
    }

    // Apply final color adjustments
    COLOR = vec4(final_col * colour_muiltiplier.rgb, 1.0) * colour_muiltiplier2;
}