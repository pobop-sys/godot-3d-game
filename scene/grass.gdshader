shader_type spatial;
render_mode unshaded, cull_back;

uniform float blade_height = 0.5;
uniform float blade_width = 0.01;
uniform float density = 0.1;

uniform vec3 base_color : source_color = vec3(0.1, 0.4, 0.1);
uniform vec3 tip_color  : source_color = vec3(0.2, 0.7, 0.2);

uniform float wind_strength = 0.0;
uniform float rnd_multiplyer = 10.0;

varying float height_ratio;

float rand(vec2 coordinates){
	return fract(
		sin(dot(coordinates, vec2(12.9898, 78.233))) * 43758.5453
	);
}

void vertex(){
	// Random per blade
	float rnd = rand(VERTEX.xz * rnd_multiplyer);

	// Density thinning (flatten instead of return)
	float visible = step(rnd, density);

	// Height variation
	float h = blade_height * (0.5 + rnd);

	// Height ratio for color blend
	height_ratio = clamp(VERTEX.y / blade_height, 0.0, 1.0);

	// Scale blade height
	VERTEX.y *= h * visible;

	// Slight random sideways lean
	float lean = (rnd - 0.5) * blade_width;
	VERTEX.x += lean * visible;
}

void fragment(){
	// Vertical gradient color
	vec3 color = mix(base_color, tip_color, height_ratio);
	ALBEDO = color;
}
