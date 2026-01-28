shader_type canvas_item;

uniform float flash_amount : hint_range(0,1) = 0.0;

void fragment() {
    // Get the sprite color at this pixel
    vec4 tex_color = texture(TEXTURE, UV);

    // Mix the sprite color with white based on flash_amount
    COLOR = mix(tex_color, vec4(1.0,1.0,1.0,tex_color.a), flash_amount);
}