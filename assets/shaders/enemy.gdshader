shader_type canvas_item;

uniform bool active = false;
uniform bool shadow = false;

uniform bool should_dissolve = false;
uniform float dissolve_sensitivity : hint_range(0.0, 1.0) = 0;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

void fragment() {
	if (!should_dissolve) {
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
	} else {
		// Get size of texture in pixels
		float size_x = float(textureSize(TEXTURE, 0).x);
		float size_y = float(textureSize(TEXTURE, 0).y);
		// 
		vec4 pixelColor = texture(TEXTURE, UV);
		// Create a new "UV" which remaps every UV value to a snapped pixel value
		vec2 UVr = vec2(floor(UV.x*size_x)/size_x, floor(UV.y*size_y)/size_y);
		// Determine whether pixel should be visible or not
		float visible = step(dissolve_sensitivity, random(UVr));
		// Draw the pixel, or not depending on if it is visible or not
		COLOR = vec4(pixelColor.r, pixelColor.g, pixelColor.b, min(visible, pixelColor.a));
	}

}

