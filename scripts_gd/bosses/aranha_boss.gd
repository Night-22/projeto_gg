extends Enemy
class_name AranhaBoss

signal chefe_derrotado

enum Estado {
	IDLE,
	ANDANDO_LADOS,
	INDO_PARA_CENTRO,
	PREPARANDO_PORRADAO,
	PORRADAO,
	PERSEGUINDO,
	PREPARANDO_ATAQUE,
	ATAQUE_TEIA,
	ATAQUE_MORDIDA,
}

var perna_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/aranha_perna.tscn")
var teia_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/teia_projetil.tscn")

@export var vida_maxima_boss := 200
@export var numero_pernas := 8


@export var limite_esquerdo := -500.0
@export var limite_direito := 500.0
@export var distancia_ate_o_chao := 400.0


@export var velocidade_movimento := 140.0
@export var margem_arena := 24.0


@export var tempo_idle_min := 1.2
@export var tempo_idle_max := 2.4
@export var tempo_preparar_ataque := 0.7
@export var tempo_perseguicao := 1.1

@export var tempo_preparar_porradao := 1.0
@export var intervalo_entre_pernas := 0.09
@export var tempo_ativo_perna := 0.22
@export var dano_porradao := 4

@export var dano_mordida := 15
@export var tempo_descida_mordida := 0.35


@export var dano_teia := 20
@export var velocidade_queda_teia := 480.0

@onready var mordida_hitbox: Area2D = $MordidaHitbox

var lutando := false
var jogador: Node2D = null

var estado_atual: int = Estado.IDLE
var estado_timer := 0.0
var direcao_movimento := 1
var proximo_ataque_perseguicao := Estado.ATAQUE_TEIA

var altura_suspensa_global := 0.0
var chao_y := 0.0

var pernas: Array[AranhaPerna] = []
var _porradao_em_andamento := false


func _ready() -> void:
	super._ready()

	Life = vida_maxima_boss
	max_elementos = 2
	element_icon_offset = Vector2(0, -90)


	altura_suspensa_global = global_position.y
	chao_y = altura_suspensa_global + distancia_ate_o_chao

	jogador = get_tree().get_first_node_in_group("Player")

	if mordida_hitbox:
		mordida_hitbox.monitoring = false

	_criar_pernas()


func iniciar_luta() -> void:
	if lutando or dead:
		return

	lutando = true
	jogador = get_tree().get_first_node_in_group("Player")
	_trocar_estado(Estado.IDLE)


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)

	if not lutando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match estado_atual:
		Estado.IDLE:
			_estado_idle(delta)
		Estado.ANDANDO_LADOS:
			_estado_andando_lados(delta)
		Estado.INDO_PARA_CENTRO:
			_estado_indo_para_centro(delta)
		Estado.PREPARANDO_PORRADAO:
			_estado_preparando_porradao(delta)
		Estado.PORRADAO:
			_estado_porradao(delta)
		Estado.PERSEGUINDO:
			_estado_perseguindo(delta)
		Estado.PREPARANDO_ATAQUE:
			_estado_preparando_ataque(delta)
		Estado.ATAQUE_TEIA:
			_estado_ataque_teia(delta)
		Estado.ATAQUE_MORDIDA:
			_estado_ataque_mordida(delta)

	move_and_slide()

	global_position.x = clamp(global_position.x, limite_esquerdo, limite_direito)

	if estado_atual != Estado.ATAQUE_MORDIDA:
		global_position.y = altura_suspensa_global


func _trocar_estado(novo: int) -> void:
	estado_atual = novo

	match novo:
		Estado.IDLE:
			modulate = Color.WHITE
			estado_timer = randf_range(tempo_idle_min, tempo_idle_max)

		Estado.ANDANDO_LADOS:
			direcao_movimento = [-1, 1][randi() % 2]
			estado_timer = randf_range(1.0, 2.0)

		Estado.PREPARANDO_PORRADAO:
			modulate = Color(1.0, 0.55, 0.55)
			estado_timer = tempo_preparar_porradao

		Estado.PORRADAO:
			_iniciar_porradao()

		Estado.PERSEGUINDO:
			estado_timer = tempo_perseguicao

		Estado.PREPARANDO_ATAQUE:
			modulate = Color(1.0, 0.55, 0.55)
			estado_timer = tempo_preparar_ataque
			proximo_ataque_perseguicao = (
				Estado.ATAQUE_TEIA if randf() < 0.5 else Estado.ATAQUE_MORDIDA
			)

		Estado.ATAQUE_TEIA:
			modulate = Color.WHITE
			_iniciar_ataque_teia()

		Estado.ATAQUE_MORDIDA:
			modulate = Color.WHITE
			_iniciar_ataque_mordida()


func _escolher_proxima_acao() -> void:
	if jogador == null or not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("Player")

	if jogador == null:
		estado_timer = tempo_idle_min
		return

	var escolha := randf()

	if escolha < 0.3:
		_trocar_estado(Estado.ANDANDO_LADOS)
	elif escolha < 0.65:
		_trocar_estado(Estado.INDO_PARA_CENTRO)
	else:
		_trocar_estado(Estado.PERSEGUINDO)


func _estado_idle(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_escolher_proxima_acao()


func _estado_andando_lados(delta: float) -> void:
	velocity.x = direcao_movimento * velocidade_movimento
	velocity.y = 0

	if global_position.x <= limite_esquerdo + margem_arena:
		direcao_movimento = 1
	elif global_position.x >= limite_direito - margem_arena:
		direcao_movimento = -1

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.IDLE)


func _estado_indo_para_centro(delta: float) -> void:
	var centro_x := (limite_esquerdo + limite_direito) / 2.0
	var direcao := signf(centro_x - global_position.x)

	velocity.x = direcao * velocidade_movimento
	velocity.y = 0

	if abs(centro_x - global_position.x) < 4.0:
		velocity.x = 0
		_trocar_estado(Estado.PREPARANDO_PORRADAO)


func _estado_perseguindo(delta: float) -> void:
	if jogador == null or not is_instance_valid(jogador):
		_trocar_estado(Estado.IDLE)
		return

	var direcao := signf(jogador.global_position.x - global_position.x)

	velocity.x = direcao * velocidade_movimento * 1.6
	velocity.y = 0

	estado_timer -= delta
	if estado_timer <= 0:
		velocity.x = 0
		_trocar_estado(Estado.PREPARANDO_ATAQUE)


func _estado_preparando_porradao(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(Estado.PORRADAO)


func _estado_preparando_ataque(delta: float) -> void:
	velocity = Vector2.ZERO

	estado_timer -= delta
	if estado_timer <= 0:
		_trocar_estado(proximo_ataque_perseguicao)


func _estado_porradao(_delta: float) -> void:
	velocity = Vector2.ZERO


func _iniciar_porradao() -> void:
	if _porradao_em_andamento:
		return

	_porradao_em_andamento = true
	_sequencia_porradao()


func _sequencia_porradao() -> void:
	var pernas_vivas: Array[AranhaPerna] = []

	for perna in pernas:
		if is_instance_valid(perna) and perna.ativa:
			pernas_vivas.append(perna)

	for perna in pernas_vivas:
		if dead:
			return

		if is_instance_valid(perna) and perna.ativa:
			perna.ativar_ataque(dano_porradao)

		await get_tree().create_timer(tempo_ativo_perna).timeout

		if is_instance_valid(perna):
			perna.desativar_ataque()

		await get_tree().create_timer(intervalo_entre_pernas).timeout

	_porradao_em_andamento = false

	if not dead:
		_trocar_estado(Estado.IDLE)


func _estado_ataque_teia(_delta: float) -> void:
	velocity = Vector2.ZERO


func _iniciar_ataque_teia() -> void:
	var teia: TeiaProjetil = teia_scene.instantiate()

	teia.global_position = Vector2(global_position.x, global_position.y + 16)
	teia.dano = dano_teia
	teia.velocidade = velocidade_queda_teia
	teia.chao_y = chao_y

	get_parent().add_child(teia)

	await get_tree().create_timer(0.4).timeout

	if not dead:
		_trocar_estado(Estado.IDLE)


func _estado_ataque_mordida(_delta: float) -> void:
	velocity = Vector2.ZERO

	if jogador and is_instance_valid(jogador):
		var direcao := signf(jogador.global_position.x - global_position.x)
		velocity.x = direcao * velocidade_movimento * 0.4


func _iniciar_ataque_mordida() -> void:
	var y_original := global_position.y
	var y_alvo := chao_y - 40.0

	if mordida_hitbox:
		mordida_hitbox.monitoring = true

	var tween := create_tween()
	tween.tween_property(self, "global_position:y", y_alvo, tempo_descida_mordida)
	tween.tween_property(self, "global_position:y", y_original, tempo_descida_mordida)
	tween.finished.connect(_finalizar_mordida)


func _finalizar_mordida() -> void:
	if mordida_hitbox:
		mordida_hitbox.monitoring = false

	if not dead:
		_trocar_estado(Estado.IDLE)


func _on_mordida_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("receber_dano"):
		body.receber_dano(dano_mordida, global_position.x)


func _criar_pernas() -> void:
	for perna in pernas:
		if is_instance_valid(perna):
			perna.queue_free()

	pernas.clear()

	if numero_pernas <= 0:
		return

	var centro_x := (limite_esquerdo + limite_direito) / 2.0
	var passo := (limite_direito - limite_esquerdo) / float(numero_pernas + 1)

	for i in range(numero_pernas):
		var perna: AranhaPerna = perna_scene.instantiate()
		var pos_x_arena := limite_esquerdo + passo * (i + 1)

		add_child(perna)
		perna.position = Vector2(pos_x_arena - centro_x, 0)
		perna.set_comprimento(distancia_ate_o_chao)

		pernas.append(perna)


func atualizar_pernas_por_vida() -> void:
	if numero_pernas <= 0:
		return

	var vivas_esperadas := ceili(
		float(max(Life, 0)) / float(vida_maxima_boss) * numero_pernas
	)
	vivas_esperadas = clampi(vivas_esperadas, 0, numero_pernas)

	var pernas_vivas_atualmente := 0
	for perna in pernas:
		if is_instance_valid(perna) and perna.ativa:
			pernas_vivas_atualmente += 1

	var quantidade_a_matar := pernas_vivas_atualmente - vivas_esperadas

	if quantidade_a_matar <= 0:
		return

	for perna in pernas:
		if quantidade_a_matar <= 0:
			break

		if is_instance_valid(perna) and perna.ativa:
			perna.matar_perna()
			quantidade_a_matar -= 1


func _dano(dano: int, origem_x: float):
	if dead:
		return

	super._dano(dano, origem_x)

	if not dead:
		atualizar_pernas_por_vida()


func reacao_enraizamento(dano: int) -> int:
	mostrar_reacao("ENRAIZAMENTO")
	return dano


func reacao_queimadura(dano: int) -> int:
	mostrar_reacao("QUEIMADURA")

	queimadura_timer = duracao_queimadura
	queimadura_tick_timer = 0.0

	return dano


func die():
	if dead:
		return

	dead = true
	lutando = false

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	for perna in pernas:
		if is_instance_valid(perna):
			perna.matar_perna()

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
