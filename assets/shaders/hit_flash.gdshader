shader_type canvas_item;

uniform bool active = false;
uniform bool shadow = false;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV).rgba;
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	vec4 new_color = previous_color;

	if (active == true)
	{
		new_color = white_color;
	}
	
	float new_alpha = 0.0;
	if (shadow == true)
	{
		new_alpha = 0.7;
	}
	
	COLOR = new_color;
	COLOR.a -= new_alpha;
}
