shader_type canvas_item;

uniform vec2 Direction = vec2(0.5, 0.5);
uniform float Speed = 0.08;
varying flat vec4 modulate;

void vertex() {
	// Called for every vertex the material is visible on.
	modulate = COLOR;
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = modulate * texture(TEXTURE, UV + (Direction * TIME * Speed));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
