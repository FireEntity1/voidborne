shader_type canvas_item;

// Fog shader by Big Boy Games (Jesse)

uniform vec2 pos = vec2(0,0);
uniform float textureResolution = 1280.0;
uniform vec2 moveDir = vec2(1.0,0.0);
uniform sampler2D noise : repeat_enable;
uniform sampler2D noise2 : repeat_enable;

varying vec4 col;

float sin_range(float minNum, float maxNum, float t) {
	float halfRange = (maxNum - minNum)/2.0;
	return minNum + halfRange + sin(t) * halfRange;
}

void vertex() {
	col = COLOR;
}

void fragment() {
	vec2 offset = pos/textureResolution;
	
	vec4 col1 = texture(noise, UV + offset - (moveDir*TIME/100.0));
	vec4 col2 = texture(noise2, UV + offset - (moveDir*TIME/20.0));
	
	col1.a = sin_range(col1.a/3.0, col1.a, TIME);
	col2.a = sin_range(col2.a/1.1, col2.a, TIME*4.0);
	
	COLOR = mix(col1, col2, col2.a)*col;
}