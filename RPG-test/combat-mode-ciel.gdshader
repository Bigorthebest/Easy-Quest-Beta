shader_type spatial;

uniform float cloud_scale = 1.5;
uniform float cloud_speed = 0.1;
uniform vec3 sky_color : source_color = vec3(0.4, 0.7, 1.0);
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float softness = 0.15;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	
	vec2 u = f * f * (3.0 - 2.0 * f);
	
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
	vec2 uv = world_pos.yz * cloud_scale;
	uv.y += TIME * cloud_speed;

	float n = noise(uv);
	float cloud_mask = smoothstep(0.5, 0.5 + softness, n);

	vec3 color = mix(sky_color, cloud_color, cloud_mask);
	ALBEDO = color;
}

void light() {
	DIFFUSE_LIGHT = ALBEDO * dot(NORMAL, LIGHT);
}
