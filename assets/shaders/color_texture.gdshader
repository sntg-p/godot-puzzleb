shader_type canvas_item;

uniform sampler2D tex1: source_color;
uniform vec4 color: source_color;

void fragment() {
	float alpha = COLOR.a;
	COLOR = texture(tex1, UV) * color;
	COLOR.a *= alpha;
}
