shader_type canvas_item;

uniform vec4 color :source_color = vec4(1.,1.,1.,1.);
uniform float scale : hint_range(0.1, 10000.0, 0.1) = 7500;
uniform float circle_ratio: hint_range(0.0, 100.0, 0.1) = 0.;
uniform float cut_radius: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float rotate_speed: hint_range(-1000, 1000, 0.01) = 1;
uniform float time_speed: hint_range(-1000, 1000, 0.01) = 1;

uniform float frequency_base: hint_range(0.0, 10.0, 0.01) = 1.;
uniform float frequency_disturbance_scale: hint_range(0.0, 10.0, 0.01) = 0.;

uniform bool stop_shine = false;

float onedx(float x) {

	if (x + 1. - 1. == 0.) {

		return 1.;
	} else {

		return 1./x;
	}
}

float onedx2(float x) {

	return  onedx(x)*onedx(x);
}

float getBetaW(float x, float f, float size) {

	return size*x*3.1415926/f;
}

float getBetaH(float y, float f, float size) {

	return size*y*3.1415926/f;
}

float getI(vec2 uv, float f, vec2 SIZE) {

	return onedx2(getBetaW(uv.x, f, SIZE.x))*onedx2(getBetaH(uv.y, f, SIZE.y));
}

vec2 rotate(vec2 uv, float addtheta) {

    //float theta = atan(uv.y/uv.x) + addtheta;
    //vec2 ruv;
    //ruv.x = cos(theta)*uv.x - sin(theta)*uv.y;
    //ruv.y = sin(theta)*uv.x + cos(theta)*uv.y;

    float theta = atan(uv.y/uv.x) + addtheta;
    float r = sqrt(uv.x*uv.x + uv.y*uv.y);
    vec2 ruv;
	ruv.x = r*cos(theta);
    ruv.y = r*sin(theta);

    return ruv;
}

void fragment() {

    vec2 st = rotate((UV - 0.5)*scale, TIME*rotate_speed);
	float r = sqrt(st.x*st.x + st.y*st.y);
    st = st*pow(r, circle_ratio);

    float time = TIME*time_speed;

    float f = frequency_base + frequency_disturbance_scale*(3.*sin(time) + 2.*cos(time*4.) + 6.*sin(time*2.) + 1.*sin(time*3.));
    float L = (r < cut_radius*scale) ? min(1.*sin(time*2.) + 5.*sin(time*3.) + 1.*sin(time*4.) + 2.*cos(time*2.), 1.) : 0.;

	f = stop_shine ? frequency_base : f;
	L = stop_shine ? ((r < cut_radius*scale) ? 1. : 0.) : L;

	COLOR = vec4(min(vec3(getI(st, f, SCREEN_PIXEL_SIZE))*L, 1.),1.0)*color;
}