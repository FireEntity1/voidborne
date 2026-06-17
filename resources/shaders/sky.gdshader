shader_type canvas_item;

uniform vec2 pixelation = vec2(256, 256); //The resolution of the Texture
uniform sampler2D cloud_noise1; //The first scroling noise for the clouds
uniform vec2 scroll_speed1 = vec2(0.02, 0.007); //The scroll-speed of the first noise
uniform sampler2D cloud_noise2; //The second scroling noise for the clouds
uniform vec2 scroll_speed2 = vec2(-0.015, -0.004); //The scroll-speed of the second noise
uniform vec2 center_pos = vec2(0.5, 0.0); //The position, the clouds are bend around
uniform float position_impact : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform sampler2D color_gardient; //The colors of the cloud-sky-transition as a 1D-Gradient (set interpolation to constant for more pixel look)

void fragment() {
	//The pixelated UV (so that the texture is actually pixelart)
	vec2 pixel_uv = floor(UV * pixelation) / pixelation;
	//Makes sure the clouds aren't stretched, even if it's not square shaped
	vec2 noise_uv_scale = pixel_uv;
	noise_uv_scale.x *= pixelation.x / pixelation.y;
	//The UVs inside the noise texture with time-offset
	vec2 noise1uv = fract(noise_uv_scale + TIME * scroll_speed1);
	vec2 noise2uv = fract(noise_uv_scale + TIME * scroll_speed2);
	//Determents the average color of the two noises
	vec4 noise_col = (texture(cloud_noise1, noise1uv) + texture(cloud_noise2, noise2uv)) * 0.5;
	//The pixels distance to the center
	float dist = distance(pixel_uv, center_pos);
	//Scales the distance to a range between 0 and 1
	vec2 furthest = vec2(-min(sign(center_pos.x - 0.5), 0.0), -min(sign(center_pos.y - 0.5), 0.0));
	float max_dist = distance(center_pos, furthest);
	dist /= max_dist;
	//Mixes the noise color with the distance to get noise that warps around the center
	float final = mix(1.0-noise_col.r, dist, position_impact);
	//applies the color from the gradient
	COLOR = texture(color_gardient, vec2(final, final));
}

