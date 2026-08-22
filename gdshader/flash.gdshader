shader_type canvas_item;

// Cor usada no flash (branco para "sem elemento", ou a cor do elemento).
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// 1.0 = sprite totalmente na cor do flash, 0.0 = sprite normal.
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

// No Godot 4 não existe um "MODULATE" acessível dentro de fragment().
// O jeito certo de preservar o modulate (cor/alpha do CanvasItem) é
// capturá-lo em vertex() através de COLOR (que ali já é modulate * self_modulate)
// e guardar numa varying para usar depois no fragment().
varying vec4 v_modulate;

void vertex() {
	v_modulate = COLOR;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 cor_final = mix(tex_color.rgb, flash_color.rgb, flash_amount);
	COLOR = vec4(cor_final, tex_color.a) * modulate;
}
