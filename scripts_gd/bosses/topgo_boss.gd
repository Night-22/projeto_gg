extends Enemy
class_name TopgoBoss

signal chefe_derrotado
signal fase_um_concluida
signal fase_dois_concluida

signal zona_fogo_escolhida(indice: int)

enum Estado {
	IDLE_AR,
	PREPARANDO_ESPINHO,
	ATAQUE_ESPINHO,
	PREPARANDO_RAIO,
	ATAQUE_RAIO,
	IDLE_GRITO,
	FASE_DOIS,


	FASE2_IDLE_MEIO,
	FASE2_IDLE_ESQUERDA,
	FASE2_IDLE_DIREITA,
	FASE2_TELEPORTANDO,
	FASE2_PREPARANDO_FOGO1,
	FASE2_ATAQUE_FOGO1,
	FASE2_PREPARANDO_AGUA,
	FASE2_ATAQUE_AGUA,
	FASE2_PREPARANDO_FOGO2,
	FASE2_ATAQUE_FOGO2,
	IDLE_GRITO2,
	FASE_TRES,

	FASE3_IDLE_MEIO,
	FASE3_IDLE_ESQUERDA,
	FASE3_IDLE_DIREITA,
	FASE3_TELEPORTANDO,
	FASE3_PREPARANDO_ESPINHO_RADIAL,
	FASE3_ATAQUE_ESPINHO_RADIAL,
	FASE3_PREPARANDO_FOGO_ZONA,
	FASE3_ATAQUE_FOGO_ZONA,
	FASE3_PREPARANDO_RAIO_VARREDURA,
	FASE3_ATAQUE_RAIO_VARREDURA,
	FASE3_PREPARANDO_SLIMES,
	FASE3_ATAQUE_SLIMES,
	IDLE_EXPLOSAO,
}

const ESTADOS_IDLE_FASE2 := [
	Estado.FASE2_IDLE_MEIO,
	Estado.FASE2_IDLE_ESQUERDA,
	Estado.FASE2_IDLE_DIREITA,
]

const PROPORCOES_ZONAS_FASE3 := [0.15, 0.15, 0.4, 0.15, 0.15]

var espinho_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/espinho_boss.tscn")
var raio_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/raio_projetil.tscn")

var minion_fogo_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/minion_fogo_boss.tscn")
var bola_agua_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/bola_agua_boss.tscn")
var chama_chao_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/chama_chao_boss.tscn")

var espinho_radial_scene = preload("res://cenas_tscn/inimigos_tscn/bosses/espinho_radial_boss.tscn")
var chama_zona_scene = preload("res://cenas_tscn/inimigos_tscn/bosses/chama_zona_boss.tscn")
var raio_varredura_scene = preload("res://cenas_tscn/inimigos_tscn/bosses/raio_varredura_boss.tscn")
var slime_agua_boss_scene = preload("res://cenas_tscn/inimigos_tscn/bosses/slime_agua_boss.tscn")

@export_group("Vida e fase")
@export var vida_maxima_boss := 180

@export var proporcao_troca_fase := 2.0 / 3.0

@export_group("Arena")
@export var limite_esquerdo := -100.0
@export var limite_direito := 300.0

@export var altura_chao := 145.0

@export_group("Flutuação (Idle_Ar)")
@export var amplitude_flutuacao := 5.0
@export var velocidade_flutuacao := 1.6
@export var tempo_idle_min := 0.8
@export var tempo_idle_max := 2.4

@export_group("Ataque de espinho (Planta)")
@export var tempo_preparar_espinho := 0.35
@export var altura_espinho := 40.0
@export var dano_espinho := 6
@export var tempo_aviso_espinho := 1.5
@export var tempo_ativo_espinho := 5
@export var tempo_pos_espinho := 0.25

@export_group("Ataque de raio (Raio)")
@export var tempo_preparar_raio := 0.3
@export var numero_raios := 4
@export var intervalo_raios := 0.2
@export var tempo_aviso_raio := 0.35
@export var tempo_ativo_raio := 0.2
@export var dano_raio := 5
@export var altura_raio := 2000.0
@export var tempo_pos_raio := 0.25

@export_group("Transição de fase")
@export var tempo_grito := 1.1

@export var proporcao_troca_fase_dois := 1.0 / 3.0

@export_group("Fase 2 - Movimentação (esquerda/meio/direita)")
@export var margem_lateral_fase2 := 40.0
@export var tempo_teleporte := 0.28
@export var tempo_idle_fase2_min := 0.6
@export var tempo_idle_fase2_max := 1.2

@export_group("Fase 2 - Ataque Fogo 1 (minions explosivos)")
@export var tempo_preparar_fogo1 := 0.25
@export var numero_minions_fogo := 3
@export var largura_zona_minions := 130.0
@export var tempo_espera_fogo1 := 0.4

@export_group("Fase 2 - Ataque Água (bolas parabólicas)")
@export var tempo_preparar_agua_fase2 := 0.25
@export var numero_bolas_agua := 3
@export var intervalo_bolas_agua := 0.22
@export var tempo_voo_bola_agua := 0.75
@export var gravidade_bola_agua := 850.0
@export var dano_bola_agua := 5
@export var tempo_espera_agua := 0.25

@export_group("Fase 2 - Ataque Fogo 2 (chão em chamas)")
@export var tempo_preparar_fogo2 := 0.35
@export var altura_chama := 40.0
@export var tempo_aviso_fogo2 := 1.3
@export var tempo_espalhar_fogo2 := 1.0
@export var tempo_ativo_fogo2 := 2.2
@export var tempo_recolher_fogo2 := 0.4
@export var dano_tick_fogo2 := 3
@export var intervalo_dano_fogo2 := 0.75

@export_group("Fase 3 - Movimentação")
@export var tempo_idle_fase3_min := 0.35
@export var tempo_idle_fase3_max := 0.75
@export var chance_movimento_fase3 := 0.18

@export_group("Fase 3 - Ataque Planta2 (espinhos radiais)")
@export var tempo_preparar_espinho_radial := 0.2
@export var numero_direcoes_espinho_radial := 7
@export var tempo_aviso_espinho_radial := 0.45
@export var tempo_ativo_espinho_radial := 0.35
@export var dano_espinho_radial := 3
@export var tempo_pos_espinho_radial := 0.2

@export_group("Fase 3 - Ataque Fogo3 (fogo em uma das 5 partes da arena)")
@export var tempo_preparar_fogo_zona := 0.2
@export var altura_fogo_zona := 40.0
@export var tempo_aviso_fogo_zona := 0.45
@export var tempo_espalhar_fogo_zona := 0.25
@export var tempo_ativo_fogo_zona := 1.0
@export var tempo_recolher_fogo_zona := 0.3
@export var dano_tick_fogo_zona := 2
@export var intervalo_dano_fogo_zona := 0.5

@export_group("Fase 3 - Ataque Raio2 (raio varrendo a arena)")
@export var tempo_preparar_raio_varredura := 0.2
@export var largura_raio_varredura := 46.0
@export var altura_raio_varredura := 2000.0
@export var velocidade_raio_varredura := 320.0
@export var tempo_aviso_raio_varredura := 0.35
@export var dano_raio_varredura := 3
@export var tempo_pos_raio_varredura := 0.2

@export_group("Fase 3 - Ataque Água2 (slimes pequenos)")
@export var tempo_preparar_slimes_agua := 0.2
@export var numero_slimes_agua := 2
@export var vida_slime_agua := 2
@export var tempo_espera_slimes_agua := 0.5

var lutando := false
var jogador: Node2D = null

var estado_atual: int = Estado.IDLE_AR
var estado_timer := 0.0

var posicao_base := Vector2.ZERO
var tempo_flutuacao := 0.0

var lado_espinho_atual := 1
var fase_dois_iniciada := false
var fase_tres_iniciada := false

# --- Fase 2 ---
var posicao_x_atual := 0.0
var posicao_x_meio := 0.0
var posicao_x_esquerda := 0.0
var posicao_x_direita := 0.0
var posicao_atual_fase2: int = Estado.FASE2_IDLE_MEIO
var posicao_atual_fase3: int = Estado.FASE3_IDLE_MEIO
var _teleporte_destino_estado: int = Estado.FASE2_IDLE_MEIO
var _teleporte_destino_x := 0.0

@onready var nucleo_planta: Sprite2D = $NucleoPlanta
@onready var nucleo_raio: Sprite2D = $NucleoRaio
@onready var nucleo_fogo: Sprite2D = $NucleoFogo
@onready var nucleo_agua: Sprite2D = $NucleoAgua


func _ready() -> void:
	super._ready()

	Life = vida_maxima_boss
	max_elementos = 2
	element_icon_offset = Vector2(0, -70)

	posicao_base = global_position
	jogador = get_tree().get_first_node_in_group("Player")

	posicao_x_meio = posicao_base.x
	posicao_x_esquerda = limite_esquerdo + margem_lateral_fase2
	posicao_x_direita = limite_direito - margem_lateral_fase2
	posicao_x_atual = posicao_x_meio


func iniciar_luta() -> void:
	if lutando or dead:
		return

	lutando = true
	jogador = get_tree().get_first_node_in_group("Player")
	_trocar_estado(Estado.IDLE_AR)


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)

	tempo_flutuacao += delta

	if not lutando:
		_flutuar()
		return

	match estado_atual:
		Estado.IDLE_AR:
			_estado_idle_ar(delta)
		Estado.PREPARANDO_ESPINHO:
			_estado_preparando_espinho(delta)
		Estado.ATAQUE_ESPINHO:
			_estado_ataque_espinho(delta)
		Estado.PREPARANDO_RAIO:
			_estado_preparando_raio(delta)
		Estado.ATAQUE_RAIO:
			_estado_ataque_raio(delta)
		Estado.IDLE_GRITO:
			_estado_idle_grito(delta)
		Estado.FASE_DOIS:
			_estado_fase_dois(delta)
		Estado.FASE2_IDLE_MEIO, Estado.FASE2_IDLE_ESQUERDA, Estado.FASE2_IDLE_DIREITA:
			_estado_fase2_idle(delta)
		Estado.FASE2_TELEPORTANDO:
			pass
		Estado.FASE2_PREPARANDO_FOGO1:
			_estado_preparando_fogo1(delta)
		Estado.FASE2_ATAQUE_FOGO1:
			pass
		Estado.FASE2_PREPARANDO_AGUA:
			_estado_preparando_agua_fase2(delta)
		Estado.FASE2_ATAQUE_AGUA:
			pass
		Estado.FASE2_PREPARANDO_FOGO2:
			_estado_preparando_fogo2(delta)
		Estado.FASE2_ATAQUE_FOGO2:
			pass
		Estado.IDLE_GRITO2:
			_estado_idle_grito2(delta)
		Estado.FASE_TRES:
			_estado_fase_tres(delta)
		Estado.FASE3_IDLE_MEIO, Estado.FASE3_IDLE_ESQUERDA, Estado.FASE3_IDLE_DIREITA:
			_estado_fase3_idle(delta)
		Estado.FASE3_TELEPORTANDO:
			pass
		Estado.FASE3_PREPARANDO_ESPINHO_RADIAL:
			_estado_preparando_espinho_radial(delta)
		Estado.FASE3_ATAQUE_ESPINHO_RADIAL:
			pass
		Estado.FASE3_PREPARANDO_FOGO_ZONA:
			_estado_preparando_fogo_zona(delta)
		Estado.FASE3_ATAQUE_FOGO_ZONA:
			pass
		Estado.FASE3_PREPARANDO_RAIO_VARREDURA:
			_estado_preparando_raio_varredura(delta)
		Estado.FASE3_ATAQUE_RAIO_VARREDURA:
			pass
		Estado.FASE3_PREPARANDO_SLIMES:
			_estado_preparando_slimes(delta)
		Estado.FASE3_ATAQUE_SLIMES:
			pass

	_flutuar()


func _flutuar() -> void:
	global_position.x = clamp(posicao_x_atual, limite_esquerdo, limite_direito)
	global_position.y = posicao_base.y + sin(tempo_flutuacao * velocidade_flutuacao) * amplitude_flutuacao


func _trocar_estado(novo: int) -> void:
	estado_atual = novo

	match novo:
		Estado.IDLE_AR:
			modulate = Color.WHITE
			estado_timer = randf_range(tempo_idle_min, tempo_idle_max)

		Estado.PREPARANDO_ESPINHO:
			modulate = Color(0.55, 1.0, 0.5)
			estado_timer = tempo_preparar_espinho
			lado_espinho_atual = -1 if randf() < 0.5 else 1

		Estado.ATAQUE_ESPINHO:
			modulate = Color.WHITE
			_invocar_espinhos()

		Estado.PREPARANDO_RAIO:
			modulate = Color(1.0, 0.95, 0.45)
			estado_timer = tempo_preparar_raio

		Estado.ATAQUE_RAIO:
			modulate = Color.WHITE
			_disparar_raios()

		Estado.IDLE_GRITO:
			modulate = Color(1.0, 0.4, 0.4)
			estado_timer = tempo_grito
			_animar_grito()

		Estado.FASE_DOIS:
			modulate = Color.WHITE
			fase_dois_iniciada = true
			_trocar_visual_para_fase_dois()
			fase_um_concluida.emit()

		Estado.FASE2_IDLE_MEIO:
			modulate = Color.WHITE
			posicao_atual_fase2 = novo
			posicao_x_atual = posicao_x_meio
			estado_timer = randf_range(tempo_idle_fase2_min, tempo_idle_fase2_max)

		Estado.FASE2_IDLE_ESQUERDA:
			modulate = Color.WHITE
			posicao_atual_fase2 = novo
			estado_timer = randf_range(tempo_idle_fase2_min, tempo_idle_fase2_max)

		Estado.FASE2_IDLE_DIREITA:
			modulate = Color.WHITE
			posicao_atual_fase2 = novo
			estado_timer = randf_range(tempo_idle_fase2_min, tempo_idle_fase2_max)

		Estado.FASE2_TELEPORTANDO:
			_iniciar_teleporte()

		Estado.FASE2_PREPARANDO_FOGO1:
			modulate = Color(1.0, 0.55, 0.35)
			estado_timer = tempo_preparar_fogo1

		Estado.FASE2_ATAQUE_FOGO1:
			modulate = Color.WHITE
			_invocar_minions_fogo()

		Estado.FASE2_PREPARANDO_AGUA:
			modulate = Color(0.4, 0.75, 1.0)
			estado_timer = tempo_preparar_agua_fase2

		Estado.FASE2_ATAQUE_AGUA:
			modulate = Color.WHITE
			_disparar_bolas_agua()

		Estado.FASE2_PREPARANDO_FOGO2:
			modulate = Color(1.0, 0.35, 0.2)
			estado_timer = tempo_preparar_fogo2

		Estado.FASE2_ATAQUE_FOGO2:
			modulate = Color.WHITE
			_invocar_chama_chao()

		Estado.IDLE_GRITO2:
			modulate = Color(1.0, 0.4, 0.4)
			estado_timer = tempo_grito
			_animar_grito()

		Estado.FASE_TRES:
			modulate = Color.WHITE
			fase_tres_iniciada = true
			_trocar_visual_para_fase_tres()
			fase_dois_concluida.emit()

		Estado.FASE3_IDLE_MEIO:
			modulate = Color.WHITE
			posicao_atual_fase3 = novo
			posicao_x_atual = posicao_x_meio
			estado_timer = randf_range(tempo_idle_fase3_min, tempo_idle_fase3_max)

		Estado.FASE3_IDLE_ESQUERDA:
			modulate = Color.WHITE
			posicao_atual_fase3 = novo
			estado_timer = randf_range(tempo_idle_fase3_min, tempo_idle_fase3_max)

		Estado.FASE3_IDLE_DIREITA:
			modulate = Color.WHITE
			posicao_atual_fase3 = novo
			estado_timer = randf_range(tempo_idle_fase3_min, tempo_idle_fase3_max)

		Estado.FASE3_TELEPORTANDO:
			_iniciar_teleporte()

		Estado.FASE3_PREPARANDO_ESPINHO_RADIAL:
			modulate = Color(0.55, 1.0, 0.5)
			estado_timer = tempo_preparar_espinho_radial

		Estado.FASE3_ATAQUE_ESPINHO_RADIAL:
			modulate = Color.WHITE
			_invocar_espinho_radial()

		Estado.FASE3_PREPARANDO_FOGO_ZONA:
			modulate = Color(1.0, 0.35, 0.2)
			estado_timer = tempo_preparar_fogo_zona

		Estado.FASE3_ATAQUE_FOGO_ZONA:
			modulate = Color.WHITE
			_invocar_fogo_zona()

		Estado.FASE3_PREPARANDO_RAIO_VARREDURA:
			modulate = Color(1.0, 0.95, 0.45)
			estado_timer = tempo_preparar_raio_varredura

		Estado.FASE3_ATAQUE_RAIO_VARREDURA:
			modulate = Color.WHITE
			_invocar_raio_varredura()

		Estado.FASE3_PREPARANDO_SLIMES:
			modulate = Color(0.4, 0.75, 1.0)
			estado_timer = tempo_preparar_slimes_agua

		Estado.FASE3_ATAQUE_SLIMES:
			modulate = Color.WHITE
			_invocar_slimes()


func _estado_idle_ar(delta: float) -> void:
	estado_timer -= delta

	if estado_timer > 0:
		return

	if _verificar_transicao_fase():
		return

	if randf() < 0.5:
		_trocar_estado(Estado.PREPARANDO_ESPINHO)
	else:
		_trocar_estado(Estado.PREPARANDO_RAIO)


func _estado_preparando_espinho(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.ATAQUE_ESPINHO)


func _estado_preparando_raio(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.ATAQUE_RAIO)


func _estado_idle_grito(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE_DOIS)


func _estado_ataque_espinho(_delta: float) -> void:
	pass


func _estado_ataque_raio(_delta: float) -> void:
	pass


func _estado_fase_dois(_delta: float) -> void:
	_trocar_estado(Estado.FASE2_IDLE_MEIO)


func _verificar_transicao_fase() -> bool:
	if fase_dois_iniciada:
		return false

	if Life <= vida_maxima_boss * proporcao_troca_fase:
		_trocar_estado(Estado.IDLE_GRITO)
		return true

	return false


func _trocar_visual_para_fase_dois() -> void:
	if nucleo_planta:
		nucleo_planta.visible = false
	if nucleo_raio:
		nucleo_raio.visible = false
	if nucleo_fogo:
		nucleo_fogo.visible = true
	if nucleo_agua:
		nucleo_agua.visible = true



func _estado_fase2_idle(delta: float) -> void:
	estado_timer -= delta

	if estado_timer > 0:
		return

	if _verificar_transicao_fase_dois():
		return

	_escolher_proxima_acao_fase2()


func _escolher_proxima_acao_fase2() -> void:
	var opcoes: Array = []

	match estado_atual:
		Estado.FASE2_IDLE_MEIO:
			opcoes = ["fogo1", "agua", "fogo2", "esquerda", "direita"]
		Estado.FASE2_IDLE_ESQUERDA:
			opcoes = ["fogo1", "agua", "fogo2", "meio"]
		Estado.FASE2_IDLE_DIREITA:
			opcoes = ["fogo1", "agua", "fogo2", "meio"]
		_:
			opcoes = ["fogo1"]

	var escolha: String = opcoes.pick_random()

	match escolha:
		"fogo1":
			_trocar_estado(Estado.FASE2_PREPARANDO_FOGO1)
		"agua":
			_trocar_estado(Estado.FASE2_PREPARANDO_AGUA)
		"fogo2":
			_trocar_estado(Estado.FASE2_PREPARANDO_FOGO2)
		"esquerda":
			_teleporte_destino_estado = Estado.FASE2_IDLE_ESQUERDA
			_teleporte_destino_x = posicao_x_esquerda
			_trocar_estado(Estado.FASE2_TELEPORTANDO)
		"direita":
			_teleporte_destino_estado = Estado.FASE2_IDLE_DIREITA
			_teleporte_destino_x = posicao_x_direita
			_trocar_estado(Estado.FASE2_TELEPORTANDO)
		"meio":
			_teleporte_destino_estado = Estado.FASE2_IDLE_MEIO
			_teleporte_destino_x = posicao_x_meio
			_trocar_estado(Estado.FASE2_TELEPORTANDO)


func _iniciar_teleporte() -> void:
	var alvo_x := _teleporte_destino_x

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, tempo_teleporte * 0.4)
	tween.tween_callback(func() -> void: posicao_x_atual = alvo_x)
	tween.tween_property(self, "modulate:a", 1.0, tempo_teleporte * 0.4)
	tween.finished.connect(_finalizar_teleporte)


func _finalizar_teleporte() -> void:
	if dead:
		return

	if _verificar_transicao_fase_dois():
		return

	_trocar_estado(_teleporte_destino_estado)



func _estado_preparando_fogo1(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE2_ATAQUE_FOGO1)


func _invocar_minions_fogo() -> void:
	var lado := -1 if randf() < 0.5 else 1
	var borda_x := limite_esquerdo if lado < 0 else limite_direito
	var direcao_para_dentro := 1 if lado < 0 else -1

	for i in range(numero_minions_fogo):
		if dead:
			return

		var offset := (float(i) + 0.5) / float(numero_minions_fogo) * largura_zona_minions
		var x: float = clamp(
			borda_x + direcao_para_dentro * offset, limite_esquerdo, limite_direito
		)

		_criar_minion_fogo(x)

	await get_tree().create_timer(tempo_espera_fogo1).timeout

	if not dead:
		_finalizar_ataque_fase2()


func _criar_minion_fogo(x: float) -> void:
	var minion: CharacterBody2D = minion_fogo_scene.instantiate()

	minion.global_position = Vector2(x, posicao_base.y + altura_chao - 16.0)

	get_parent().add_child(minion)



func _estado_preparando_agua_fase2(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE2_ATAQUE_AGUA)


func _disparar_bolas_agua() -> void:
	for i in range(numero_bolas_agua):
		if dead:
			return

		_criar_bola_agua()

		await get_tree().create_timer(intervalo_bolas_agua).timeout

	if dead:
		return

	await get_tree().create_timer(tempo_espera_agua).timeout

	if not dead:
		_finalizar_ataque_fase2()


func _criar_bola_agua() -> void:
	var bola: Area2D = bola_agua_scene.instantiate()

	var origem := global_position + Vector2(0, -20.0)
	var alvo_x := global_position.x

	if jogador and is_instance_valid(jogador):
		alvo_x = jogador.global_position.x + randf_range(-30.0, 30.0)

	alvo_x = clamp(alvo_x, limite_esquerdo, limite_direito)

	var chao_alvo_y := posicao_base.y + altura_chao

	var dx := alvo_x - origem.x
	var dy := chao_alvo_y - origem.y

	var vx := dx / tempo_voo_bola_agua
	var vy := (
		(dy - 0.5 * gravidade_bola_agua * tempo_voo_bola_agua * tempo_voo_bola_agua)
		/ tempo_voo_bola_agua
	)

	bola.global_position = origem
	bola.velocidade = Vector2(vx, vy)
	bola.gravidade = gravidade_bola_agua
	bola.chao_y = chao_alvo_y
	bola.dano = dano_bola_agua

	get_parent().add_child(bola)



func _estado_preparando_fogo2(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE2_ATAQUE_FOGO2)


func _invocar_chama_chao() -> void:
	var lado := -1 if randf() < 0.5 else 1
	var origem_x = -50 if lado < 0 else 407

	var chama: Area2D = chama_chao_scene.instantiate()

	chama.global_position = Vector2(origem_x, posicao_base.y + altura_chao)
	chama.largura_total = 500
	chama.altura = altura_chama
	chama.lado_inicial = lado
	chama.tempo_aviso = tempo_aviso_fogo2
	chama.tempo_espalhar = tempo_espalhar_fogo2
	chama.tempo_ativo = tempo_ativo_fogo2
	chama.tempo_recolher = tempo_recolher_fogo2
	chama.dano_tick = dano_tick_fogo2
	chama.intervalo_dano = intervalo_dano_fogo2

	get_parent().add_child(chama)

	var duracao_total := (
		tempo_aviso_fogo2 + tempo_espalhar_fogo2 + tempo_ativo_fogo2 + tempo_recolher_fogo2
	)

	await get_tree().create_timer(duracao_total).timeout

	if not dead:
		_finalizar_ataque_fase2()


func _finalizar_ataque_fase2() -> void:
	if dead:
		return

	if _verificar_transicao_fase_dois():
		return

	_trocar_estado(posicao_atual_fase2)


func _estado_idle_grito2(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE_TRES)


func _verificar_transicao_fase_dois() -> bool:
	if fase_tres_iniciada:
		return false

	if Life <= vida_maxima_boss * proporcao_troca_fase_dois:
		_trocar_estado(Estado.IDLE_GRITO2)
		return true

	return false


func _trocar_visual_para_fase_tres() -> void:
	if nucleo_planta:
		nucleo_planta.visible = true
	if nucleo_raio:
		nucleo_raio.visible = true
	if nucleo_fogo:
		nucleo_fogo.visible = true
	if nucleo_agua:
		nucleo_agua.visible = true



func _estado_fase_tres(_delta: float) -> void:
	_trocar_estado(Estado.FASE3_IDLE_MEIO)


func _estado_fase3_idle(delta: float) -> void:
	estado_timer -= delta

	if estado_timer > 0:
		return

	_escolher_proxima_acao_fase3()


func _escolher_proxima_acao_fase3() -> void:
	if estado_atual == Estado.FASE3_IDLE_MEIO and randf() < chance_movimento_fase3:
		var vai_esquerda := randf() < 0.5

		_teleporte_destino_estado = (
			Estado.FASE3_IDLE_ESQUERDA if vai_esquerda else Estado.FASE3_IDLE_DIREITA
		)
		_teleporte_destino_x = posicao_x_esquerda if vai_esquerda else posicao_x_direita
		_trocar_estado(Estado.FASE3_TELEPORTANDO)
		return

	if estado_atual != Estado.FASE3_IDLE_MEIO and randf() < chance_movimento_fase3:
		_teleporte_destino_estado = Estado.FASE3_IDLE_MEIO
		_teleporte_destino_x = posicao_x_meio
		_trocar_estado(Estado.FASE3_TELEPORTANDO)
		return

	
	var opcoes := ["espinho_radial", "fogo_zona", "raio_varredura", "slimes"]
	var escolha: String = opcoes.pick_random()

	match escolha:
		"espinho_radial":
			_trocar_estado(Estado.FASE3_PREPARANDO_ESPINHO_RADIAL)
		"fogo_zona":
			_trocar_estado(Estado.FASE3_PREPARANDO_FOGO_ZONA)
		"raio_varredura":
			_trocar_estado(Estado.FASE3_PREPARANDO_RAIO_VARREDURA)
		"slimes":
			_trocar_estado(Estado.FASE3_PREPARANDO_SLIMES)


func _zonas_fase3() -> Array:
	var zonas: Array = []
	var largura_total := limite_direito - limite_esquerdo
	var x := limite_esquerdo

	for proporcao in PROPORCOES_ZONAS_FASE3:
		var largura_zona: float = largura_total * proporcao
		zonas.append([x, x + largura_zona])
		x += largura_zona

	return zonas


func _finalizar_ataque_fase3() -> void:
	if dead:
		return

	_trocar_estado(posicao_atual_fase3)



func _estado_preparando_espinho_radial(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE3_ATAQUE_ESPINHO_RADIAL)


func _invocar_espinho_radial() -> void:
	var espinho: Node2D = espinho_radial_scene.instantiate()

	espinho.global_position = global_position
	espinho.numero_direcoes = numero_direcoes_espinho_radial
	espinho.dano = dano_espinho_radial
	espinho.tempo_aviso = tempo_aviso_espinho_radial
	espinho.tempo_ativo = tempo_ativo_espinho_radial

	get_parent().add_child(espinho)

	await get_tree().create_timer(
		tempo_aviso_espinho_radial + tempo_ativo_espinho_radial + tempo_pos_espinho_radial
	).timeout

	if not dead:
		_finalizar_ataque_fase3()


func _estado_preparando_fogo_zona(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE3_ATAQUE_FOGO_ZONA)


func _invocar_fogo_zona() -> void:
	var zonas := _zonas_fase3()
	var indice := randi_range(0, zonas.size() - 1)
	var zona: Array = zonas[indice]
	var largura_zona: float = zona[1] - zona[0]
	var centro_zona: float = (zona[0] + zona[1]) / 2.0

	zona_fogo_escolhida.emit(indice)

	var chama: Area2D = chama_zona_scene.instantiate()

	chama.global_position = Vector2(centro_zona, posicao_base.y + altura_chao)
	chama.largura_total = largura_zona
	chama.altura = altura_fogo_zona
	chama.tempo_aviso = tempo_aviso_fogo_zona
	chama.tempo_espalhar = tempo_espalhar_fogo_zona
	chama.tempo_ativo = tempo_ativo_fogo_zona
	chama.tempo_recolher = tempo_recolher_fogo_zona
	chama.dano_tick = dano_tick_fogo_zona
	chama.intervalo_dano = intervalo_dano_fogo_zona

	get_parent().add_child(chama)

	var duracao_total := (
		tempo_aviso_fogo_zona + tempo_espalhar_fogo_zona
		+ tempo_ativo_fogo_zona + tempo_recolher_fogo_zona
	)

	await get_tree().create_timer(duracao_total).timeout

	if not dead:
		_finalizar_ataque_fase3()



func _estado_preparando_raio_varredura(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE3_ATAQUE_RAIO_VARREDURA)


func _invocar_raio_varredura() -> void:
	var vem_da_esquerda := randf() < 0.5
	var origem_x := limite_esquerdo if vem_da_esquerda else limite_direito
	var direcao := 1.0 if vem_da_esquerda else -1.0

	var raio: Node2D = raio_varredura_scene.instantiate()

	raio.global_position = Vector2(origem_x, posicao_base.y + altura_chao)
	raio.largura = largura_raio_varredura
	raio.altura = altura_raio_varredura
	raio.velocidade = velocidade_raio_varredura
	raio.direcao = direcao
	raio.limite_esquerdo = limite_esquerdo
	raio.limite_direito = limite_direito
	raio.tempo_aviso = tempo_aviso_raio_varredura
	raio.dano = dano_raio_varredura

	get_parent().add_child(raio)

	var distancia := limite_direito - limite_esquerdo
	var duracao_total := (
		tempo_aviso_raio_varredura
		+ (distancia / velocidade_raio_varredura)
		+ tempo_pos_raio_varredura
	)

	await get_tree().create_timer(duracao_total).timeout

	if not dead:
		_finalizar_ataque_fase3()



func _estado_preparando_slimes(delta: float) -> void:
	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.FASE3_ATAQUE_SLIMES)


func _invocar_slimes() -> void:
	var zonas := _zonas_fase3()
	var zona_meio: Array = zonas[2]

	for i in range(numero_slimes_agua):
		if dead:
			return

		var x: float = clamp(
			randf_range(zona_meio[0], zona_meio[1]), limite_esquerdo, limite_direito
		)

		_criar_slime_agua(x)

	await get_tree().create_timer(tempo_espera_slimes_agua).timeout

	if not dead:
		_finalizar_ataque_fase3()


func _criar_slime_agua(x: float) -> void:
	var slime: CharacterBody2D = slime_agua_boss_scene.instantiate()

	slime.global_position = Vector2(x, posicao_base.y + altura_chao - 16.0)
	slime.Life = vida_slime_agua

	get_parent().add_child(slime)


func _invocar_espinhos() -> void:
	var metade_arena := (limite_direito - limite_esquerdo) / 2.0
	var centro_x: float

	if lado_espinho_atual < 0:
		centro_x = limite_esquerdo + metade_arena / 2.0
	else:
		centro_x = limite_direito - metade_arena / 2.0

	var espinho: EspinhoBoss = espinho_scene.instantiate()

	espinho.global_position = Vector2(centro_x, posicao_base.y + altura_chao)
	espinho.largura = metade_arena
	espinho.altura = altura_espinho
	espinho.dano = dano_espinho
	espinho.tempo_aviso = tempo_aviso_espinho
	espinho.tempo_ativo = tempo_ativo_espinho

	get_parent().add_child(espinho)

	await get_tree().create_timer(
		tempo_aviso_espinho + tempo_ativo_espinho + tempo_pos_espinho
	).timeout

	if not dead:
		_finalizar_ataque()


func _disparar_raios() -> void:
	for i in range(numero_raios):
		if dead:
			return

		_criar_raio()

		await get_tree().create_timer(intervalo_raios).timeout

	if dead:
		return

	await get_tree().create_timer(tempo_pos_raio).timeout

	if not dead:
		_finalizar_ataque()


func _criar_raio() -> void:
	var raio: RaioProjetil = raio_scene.instantiate()

	var alvo_x := randf_range(limite_esquerdo, limite_direito)

	raio.global_position = Vector2(alvo_x, posicao_base.y + altura_chao)
	raio.altura = altura_raio
	raio.tempo_aviso = tempo_aviso_raio
	raio.tempo_ativo = tempo_ativo_raio
	raio.dano = dano_raio

	get_parent().add_child(raio)


func _finalizar_ataque() -> void:
	if dead:
		return

	if _verificar_transicao_fase():
		return

	_trocar_estado(Estado.IDLE_AR)


func _animar_grito() -> void:
	var escala_base := scale

	var tween := create_tween()
	tween.tween_property(
		self, "scale", escala_base * 1.18, tempo_grito * 0.35
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, "scale", escala_base, tempo_grito * 0.65
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	if jogador and is_instance_valid(jogador) and jogador.has_method("tremer_camera"):
		jogador.tremer_camera(4.0, tempo_grito)


func die() -> void:
	if dead:
		return

	dead = true
	lutando = false

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	mostrar_reacao("DERROTADO")
	chefe_derrotado.emit()

	if fase_tres_iniciada:
		estado_atual = Estado.IDLE_EXPLOSAO
		_animar_explosao_final()
	else:
		_finalizar_morte()


func _animar_explosao_final() -> void:
	var explosion_scene := preload("res://particles/explosion.tscn")

	if jogador and is_instance_valid(jogador) and jogador.has_method("tremer_camera"):
		jogador.tremer_camera(7.0, 1.0)

	for i in range(4):
		if not is_instance_valid(self):
			return

		var explosao: Node2D = explosion_scene.instantiate()
		explosao.global_position = global_position + Vector2(
			randf_range(-24.0, 24.0), randf_range(-24.0, 24.0)
		)
		get_parent().add_child(explosao)

		await get_tree().create_timer(0.18).timeout

	if is_instance_valid(self):
		_finalizar_morte()


func _finalizar_morte() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 1.2)
	tween.tween_property(
		self, "position:y", position.y + 40.0, 1.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
