shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;

uniform float intensity;
uniform float speed;
instance uniform vec4 color: source_color;

void vertex() {
	float t = TIME;
	if (VERTEX.y >= 0.5) {
		VERTEX.y += cos(VERTEX.x * t * speed) * cos(VERTEX.z * t * speed) * intensity;
	}
	
	if (NORMAL.y >= 0.8) {
		COLOR.a = 0.0;
	}
}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = 5.0 * COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
