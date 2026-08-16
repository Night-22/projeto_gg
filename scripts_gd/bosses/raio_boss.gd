extends Enemy
class_name RaioBoss

signal chefe_derrotado

enum Estado {
	IDLE_CHAO,
	ANDANDO,
	PREPARANDO_ATAQUE_CHAO,
	ATAQUE_CHAO_DASH,
	ATAQUE_CHAO_BOLAS,
	RECUPERANDO_QUEDA,
	TRANSICAO_PARA_PLATAFORMA,
	IDLE_PLATAFORMA,
	PREPARANDO_ATAQUE_PLATAFORMA,
	ATAQUE_PLATAFORMA,
	TRANSICAO_PARA_CHAO,
}

const ESTADOS_CHAO := [
	Estado.IDLE_CHAO,
	Estado.ANDANDO,
	Estado.PREPARANDO_ATAQUE_CHAO,
	Estado.ATAQUE_CHAO_DASH,
	Estado.ATAQUE_CHAO_BOLAS,
	Estado.RECUPERANDO_QUEDA,
]

const ESTADOS_PLATAFORMA := [
	Estado.IDLE_PLATAFORMA,
	Estado.PREPARANDO_ATAQUE_PLATAFORMA,
	Estado.ATAQUE_PLATAFORMA,
]

var raio_projetil_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/raio_projetil.tscn")
var bola_raio_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/bola_raio.tscn")

@export var vida_maxima_boss := 260
@export var limite_esquerdo := -50.0
@export var limite_direito := 400.0


@export var distancia_plataforma_chao := 50.0
@export var posicoes_plataformas: PackedFloat32Array = PackedFloat32Array([-70.0, 180.0, 290.0])


@export var velocidade_movimento := 80.0
@export var distancia_para_atacar := 90.0

@export var tempo_idle_min := 0.8
@export var tempo_idle_max := 1.6
@export var tempo_andar_maximo := 2.5
@export var tempo_preparar_ataque_chao := 0.6
@export var chance_continuar_atacando := 0.5
@export var tempo_recuperacao_queda := 0.5


@export var velocidade_dash := 250.0
@export var tempo_dash := 0.35
@export var dano_dash := 4


@export var numero_bolas_raio := 5
@export var intervalo_bolas_raio := 0.18
@export var tempo_voo_bola_raio := 0.85
@export var gravidade_bola_raio := 900.0
@export var dano_bola_raio := 8


@export var tempo_preparar_ataque_plataforma := 0.9
@export var tempo_aviso_raio := 0.4
@export var tempo_ativo_raio := 0.25
@export var altura_raio := 2000.0
@export var dano_raio_plataforma := 12


@export var tempo_transicao := 0.55

@onready var dash_hitbox: Area2D = $DashHitbox

var lutando := false
var jogador: Node2D = null

var estado_atual: int = Estado.IDLE_PLATAFORMA
var estado_timer := 0.0

var plataforma_y := 0.0
var chao_y := 0

var direcao_dash := 1.0
var _dash_acertou := false

var proximo_ataque_chao: int = Estado.ATAQUE_CHAO_DASH
var posicao_marcada_raio := 0.0


func _ready() -> void:
	super._ready()

	Life = vida_maxima_boss
	max_elementos = 2
	element_icon_offset = Vector2(0, -90)

	plataforma_y = global_position.y
	chao_y = plataforma_y + distancia_plataforma_chao

	jogador = get_tree().get_first_node_in_group("Player")

	if dash_hitbox:
		dash_hitbox.monitoring = false


func iniciar_luta() -> void:
	if lutando or dead:
		return

	lutando = true
	jogador = get_tree().get_first_node_in_group("Player")
	_trocar_estado(Estado.IDLE_PLATAFORMA)


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)

	if not lutando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match estado_atual:
		Estado.IDLE_CHAO:
			_estado_idle_chao(delta)
		Estado.ANDANDO:
			_estado_andando(delta)
		Estado.PREPARANDO_ATAQUE_CHAO:
			_estado_preparando_ataque_chao(delta)
		Estado.ATAQUE_CHAO_DASH:
			_estado_ataque_chao_dash(delta)
		Estado.ATAQUE_CHAO_BOLAS:
			_estado_ataque_chao_bolas(delta)
		Estado.RECUPERANDO_QUEDA:
			_estado_recuperando_queda(delta)
		Estado.TRANSICAO_PARA_PLATAFORMA:
			_estado_transicao_para_plataforma(delta)
		Estado.IDLE_PLATAFORMA:
			_estado_idle_plataforma(delta)
		Estado.PREPARANDO_ATAQUE_PLATAFORMA:
			_estado_preparando_ataque_plataforma(delta)
		Estado.ATAQUE_PLATAFORMA:
			_estado_ataque_plataforma(delta)
		Estado.TRANSICAO_PARA_CHAO:
			_estado_transicao_para_chao(delta)

	move_and_slide()

	global_position.x = clamp(global_position.x, limite_esquerdo, limite_direito)

	if estado_atual in ESTADOS_CHAO:
		global_position.y = chao_y
	elif estado_atual in ESTADOS_PLATAFORMA:
		global_position.y = plataforma_y


func _trocar_estado(novo: int) -> void:
	estado_atual = novo

	match novo:
		Estado.IDLE_CHAO:
			modulate = Color.WHITE
			velocity = Vector2.ZERO
			estado_timer = randf_range(tempo_idle_min, tempo_idle_max)

		Estado.ANDANDO:
			estado_timer = tempo_andar_maximo

		Estado.PREPARANDO_ATAQUE_CHAO:
			modulate = Color(1.0, 0.6, 0.3)
			velocity = Vector2.ZERO
			estado_timer = tempo_preparar_ataque_chao
			proximo_ataque_chao = (
				Estado.ATAQUE_CHAO_DASH if randf() < 0.5 else Estado.ATAQUE_CHAO_BOLAS
			)

		Estado.ATAQUE_CHAO_DASH:
			modulate = Color.WHITE
			_iniciar_dash()

		Estado.ATAQUE_CHAO_BOLAS:
			modulate = Color.WHITE
			_iniciar_bolas_de_raio()

		Estado.RECUPERANDO_QUEDA:
			modulate = Color.WHITE
			velocity = Vector2.ZERO
			estado_timer = tempo_recuperacao_queda

		Estado.TRANSICAO_PARA_PLATAFORMA:
			modulate = Color.WHITE
			_iniciar_transicao_para_plataforma()

		Estado.IDLE_PLATAFORMA:
			modulate = Color.WHITE
			velocity = Vector2.ZERO
			estado_timer = randf_range(tempo_idle_min, tempo_idle_max)

		Estado.PREPARANDO_ATAQUE_PLATAFORMA:
			modulate = Color(0.8, 0.6, 1.0)
			velocity = Vector2.ZERO
			estado_timer = tempo_preparar_ataque_plataforma
			_marcar_posicao_raio()

		Estado.ATAQUE_PLATAFORMA:
			modulate = Color.WHITE
			_iniciar_ataque_plataforma()

		Estado.TRANSICAO_PARA_CHAO:
			modulate = Color.WHITE
			_iniciar_transicao_para_chao()


func _estado_idle_chao(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.ANDANDO)


func _estado_andando(delta: float) -> void:
	if jogador == null or not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("Player")

	if jogador == null:
		velocity = Vector2.ZERO
		_trocar_estado(Estado.PREPARANDO_ATAQUE_CHAO)
		return

	var direcao := signf(jogador.global_position.x - global_position.x)
	velocity.x = direcao * velocidade_movimento
	velocity.y = 0

	estado_timer -= delta

	if abs(jogador.global_position.x - global_position.x) <= distancia_para_atacar:
		velocity.x = 0
		_trocar_estado(Estado.PREPARANDO_ATAQUE_CHAO)
	elif estado_timer <= 0:
		velocity.x = 0
		_trocar_estado(Estado.PREPARANDO_ATAQUE_CHAO)


func _estado_preparando_ataque_chao(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(proximo_ataque_chao)


func _estado_ataque_chao_dash(delta: float) -> void:
	velocity.x = direcao_dash * velocidade_dash
	velocity.y = 0

	estado_timer -= delta
	if estado_timer <= 0:
		_finalizar_dash()


func _estado_ataque_chao_bolas(_delta: float) -> void:
	velocity = Vector2.ZERO


func _estado_recuperando_queda(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.PREPARANDO_ATAQUE_CHAO)


func _estado_transicao_para_plataforma(_delta: float) -> void:
	velocity = Vector2.ZERO


func _estado_idle_plataforma(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.PREPARANDO_ATAQUE_PLATAFORMA)


func _estado_preparando_ataque_plataforma(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.ATAQUE_PLATAFORMA)


func _estado_ataque_plataforma(_delta: float) -> void:
	velocity = Vector2.ZERO


func _estado_transicao_para_chao(_delta: float) -> void:
	velocity = Vector2.ZERO


func _iniciar_dash() -> void:
	var alvo_x := global_position.x

	if jogador and is_instance_valid(jogador):
		alvo_x = jogador.global_position.x

	direcao_dash = signf(alvo_x - global_position.x)
	if direcao_dash == 0:
		direcao_dash = 1.0

	_dash_acertou = false

	if dash_hitbox:
		dash_hitbox.monitoring = true

	estado_timer = tempo_dash


func _finalizar_dash() -> void:
	velocity = Vector2.ZERO

	if dash_hitbox:
		dash_hitbox.monitoring = false

	_finalizar_ataque_chao()


func _iniciar_bolas_de_raio() -> void:
	_disparar_bolas_de_raio()


func _disparar_bolas_de_raio() -> void:
	var alvo_x := global_position.x

	if jogador and is_instance_valid(jogador):
		alvo_x = jogador.global_position.x

	for i in range(numero_bolas_raio):
		if dead:
			return

		_criar_bola_raio(alvo_x + randf_range(-40.0, 40.0))

		await get_tree().create_timer(intervalo_bolas_raio).timeout

	if not dead:
		_finalizar_ataque_chao()


func _criar_bola_raio(alvo_x: float) -> void:
	var bola: BolaRaio = bola_raio_scene.instantiate()

	var origem := global_position + Vector2(0, -60)

	var dx := alvo_x - origem.x
	var dy := chao_y - origem.y

	var vx := dx / tempo_voo_bola_raio
	var vy := (
		(dy - 0.5 * gravidade_bola_raio * tempo_voo_bola_raio * tempo_voo_bola_raio)
		/ tempo_voo_bola_raio
	)

	bola.global_position = origem
	bola.velocidade = Vector2(vx, vy)
	bola.gravidade = gravidade_bola_raio
	bola.chao_y = chao_y
	bola.dano = dano_bola_raio

	get_parent().add_child(bola)


func _finalizar_ataque_chao() -> void:
	if dead:
		return

	if randf() < chance_continuar_atacando:
		_trocar_estado(Estado.IDLE_CHAO)
	else:
		_trocar_estado(Estado.TRANSICAO_PARA_PLATAFORMA)


func _iniciar_transicao_para_plataforma() -> void:
	velocity = Vector2.ZERO

	var alvo_x := _plataforma_mais_proxima()

	var tween := create_tween()
	tween.tween_property(
		self, "global_position", Vector2(alvo_x, plataforma_y), tempo_transicao
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_finalizar_transicao_para_plataforma)


func _finalizar_transicao_para_plataforma() -> void:
	if not dead:
		_trocar_estado(Estado.IDLE_PLATAFORMA)


func _plataforma_mais_proxima() -> float:
	if posicoes_plataformas.size() == 0:
		return global_position.x

	var mais_proxima = posicoes_plataformas[0]
	var menor_distancia = abs(mais_proxima - global_position.x)

	for x in posicoes_plataformas:
		var distancia = abs(x - global_position.x)

		if distancia < menor_distancia:
			menor_distancia = distancia
			mais_proxima = x

	return mais_proxima


func _marcar_posicao_raio() -> void:
	if jogador and is_instance_valid(jogador):
		posicao_marcada_raio = jogador.global_position.x
	else:
		posicao_marcada_raio = global_position.x


func _iniciar_ataque_plataforma() -> void:
	var raio: RaioProjetil = raio_projetil_scene.instantiate()

	raio.global_position = Vector2(posicao_marcada_raio, 1000)
	raio.altura = altura_raio
	raio.tempo_aviso = tempo_aviso_raio
	raio.tempo_ativo = tempo_ativo_raio
	raio.dano = dano_raio_plataforma

	get_parent().add_child(raio)

	await get_tree().create_timer(tempo_aviso_raio + tempo_ativo_raio + 0.15).timeout

	if not dead:
		_finalizar_ataque_plataforma()


func _finalizar_ataque_plataforma() -> void:
	if dead:
		return

	if randf() < chance_continuar_atacando:
		_trocar_estado(Estado.IDLE_PLATAFORMA)
	else:
		_trocar_estado(Estado.TRANSICAO_PARA_CHAO)


func _iniciar_transicao_para_chao() -> void:
	velocity = Vector2.ZERO

	var tween := create_tween()
	tween.tween_property(
		self, "global_position:y", chao_y, tempo_transicao
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(_finalizar_transicao_para_chao)


func _finalizar_transicao_para_chao() -> void:
	if not dead:
		_trocar_estado(Estado.RECUPERANDO_QUEDA)


func _on_dash_hitbox_body_entered(body: Node2D) -> void:
	if _dash_acertou:
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		_dash_acertou = true
		body.receber_dano(dano_dash, global_position.x)


func die() -> void:
	if dead:
		return

	dead = true
	lutando = false

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if dash_hitbox:
		dash_hitbox.monitoring = false

	mostrar_reacao("MORTA")
	chefe_derrotado.emit()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees", 85.0, 1.1)
	tween.tween_property(
		self, "position:y", position.y + 220.0, 1.1
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 1.4)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
