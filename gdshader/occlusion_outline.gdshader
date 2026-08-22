shader_type canvas_item;
render_mode unshaded, blend_mix;

// Made by Seed from Kode Game Studio !

uniform vec4 outline_color : source_color = vec4(1.0, 0.6, 0.0, 1.0); // Color of the outline
uniform int outline_size : hint_range(1, 5) = 2;                      // Thickness of the outline
uniform float alpha_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;     // Alpha threshold for transparency

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float a = tex.a;
    vec4 result = vec4(0.0);

    // Only draw the outline if the current pixel is transparent
    if (a <= alpha_threshold) {
        vec2 px = TEXTURE_PIXEL_SIZE;
        float maxa = 0.0;

        // Check surrounding pixels within the outline range
        for (int x = -outline_size; x <= outline_size; x++) {
            for (int y = -outline_size; y <= outline_size; y++) {
                if (x == 0 && y == 0) continue;
                vec2 offs = vec2(float(x), float(y)) * px;
                maxa = max(maxa, texture(TEXTURE, UV + offs).a);
            }
        }

        // If any neighbor pixel is opaque, draw the outline color
        if (maxa > alpha_threshold) {
            result = outline_color;
        }
    }

    COLOR = result;
}
