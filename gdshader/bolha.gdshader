shader_type canvas_item;

uniform vec2 dimensions = vec2(320.0, 240.0);

// Quantidade de bolhas
uniform float rows = 14.0;
uniform float columns = 7.0;

// Correnteza para cima
uniform float flow_speed : hint_range(-2.0, 2.0, 0.01) = 0.65;

// Movimento lateral
uniform float horizontal_wave : hint_range(0.0, 1.0, 0.01) = 0.10;

// Oscilação
uniform float wave_speed : hint_range(0.0, 5.0, 0.1) = 1.2;

// Tamanho
uniform float size_min : hint_range(0.05, 1.0, 0.01) = 0.18;
uniform float size_max : hint_range(0.05, 1.0, 0.01) = 0.38;

// Pixelização
uniform float pixel_size : hint_range(2.0, 16.0, 1.0) = 8.0;

// Cores
uniform vec4 bubble_color : source_color = vec4(0.75, 0.95, 1.0, 0.65);
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 0.85);


float random(vec2 p) {
	return fract(
		sin(dot(p, vec2(12.9898, 78.233))) *
		43758.5453
	);
}


void fragment() {

	float time = TIME;

	// ==========================================
	// GRID
	// ==========================================

	float cell_x = UV.x * columns;
	float cell_y = UV.y * rows;

	float column_id = floor(cell_x);
	float row_id = floor(cell_y);

	float seed = random(vec2(column_id, row_id));


	// ==========================================
	// CORRENTEZA PARA CIMA
	// ==========================================

	float vertical_flow = time * flow_speed;

	vertical_flow *= mix(
		0.8,
		1.2,
		random(vec2(column_id, 50.0))
	);

	// Movimento vertical
	float y = cell_y + vertical_flow;

	// Movimento lateral
	float wave = sin(
		time * wave_speed +
		y * 2.5 +
		seed * 20.0
	);

	float x = cell_x + wave * horizontal_wave;


	// ==========================================
	// POSIÇÃO LOCAL DA CÉLULA
	// ==========================================

	vec2 local_uv = fract(vec2(x, y));


	// ==========================================
	// PIXEL ART
	// ==========================================

	local_uv =
		floor(local_uv * pixel_size) /
		pixel_size;


	vec2 bubble_uv =
		local_uv * 2.0 - 1.0;


	// ==========================================
	// CORREÇÃO DE PROPORÇÃO
	// ==========================================

	// IMPORTANTE:
	// leva em consideração:
	// - resolução
	// - quantidade de colunas
	// - quantidade de linhas
	//
	// Isso mantém a bolha circular.

	bubble_uv.x *=
		(dimensions.x / dimensions.y) *
		(rows / columns);


	// ==========================================
	// TAMANHO
	// ==========================================

	float size = mix(
		size_min,
		size_max,
		seed
	);

	size *=
		0.9 +
		sin(time * 1.5 + seed * 10.0) * 0.05;


	// ==========================================
	// DISTÂNCIA CIRCULAR
	// ==========================================

	float dist = length(bubble_uv);


	// ==========================================
	// CORPO DA BOLHA
	// ==========================================

	float bubble =
		step(dist, size);


	// Interior
	float inner =
		step(dist, size * 0.55);

	bubble -= inner * 0.35;


	// ==========================================
	// BORDA
	// ==========================================

	float border =
		step(dist, size) -
		step(dist, size * 0.78);


	// ==========================================
	// BRILHO
	// ==========================================

	vec2 highlight_offset =
		vec2(
			-size * 0.30,
			-size * 0.30
		);

	float highlight_dist =
		length(
			bubble_uv - highlight_offset
		);

	float highlight =
		step(
			highlight_dist,
			size * 0.22
		);


	// ==========================================
	// COR FINAL
	// ==========================================

	vec3 final_color =
		bubble_color.rgb;

	final_color = mix(
		final_color,
		highlight_color.rgb,
		highlight
	);


	// ==========================================
	// ALPHA
	// ==========================================

	float alpha =
		(
			bubble * 0.65 +
			border * 0.8 +
			highlight * 0.9
		) *
		bubble_color.a;


	COLOR.rgb = final_color;
	COLOR.a = alpha;
}