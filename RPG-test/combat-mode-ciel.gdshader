shader_type spatial;

uniform vec3 grass_color : source_color = vec3(0.2, 0.6, 0.2);
uniform vec3 dirt_color : source_color = vec3(0.25, 0.2, 0.1);
uniform float contrast = 4.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash(vec2 p) {
	// Génère un pseudo bruit simple
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 coord = world_pos.xz * 10.0 + vec2(0.0,TIME) + 0.7 ;
	float noise = hash(floor(coord));

	// Mélange entre herbe et terre selon le bruit
	float t = smoothstep(0.4, 0.6, noise * 1.5);
	vec3 color = mix(grass_color, dirt_color, t);

	ALBEDO = color;
}

void light() {
	DIFFUSE_LIGHT = ALBEDO * dot(NORMAL, LIGHT);
}
