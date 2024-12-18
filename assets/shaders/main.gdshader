shader_type canvas_item;

void vertex() {
  VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

uniform float blue = 1.0; // you can assign a default value to uniforms

void fragment() {
  COLOR = texture(TEXTURE, UV); // Read from texture
  COLOR.b = blue;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
