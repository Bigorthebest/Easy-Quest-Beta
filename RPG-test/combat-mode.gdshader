shader_type spatial;

varying vec3 world_pos;

// Fonction utilitaire pour convertir HSV → RGB
vec3 hsv2rgb(vec3 c) {
	vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return c.z * mix(vec3(1.0), rgb, c.y);
}

void vertex() {
	// Passe la position mondiale au fragment shader
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float speed = 0.5;
	float hue = fract(world_pos.y * 0.5 + TIME * speed);

	ALBEDO = hsv2rgb(vec3(hue, 1.0, 1.0));
}

void light() {
	DIFFUSE_LIGHT = ALBEDO * dot(NORMAL, LIGHT);
}
