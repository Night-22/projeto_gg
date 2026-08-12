extends CharacterBody2D
class_name Enemy

@export var Life = 50
@export var Speed = 60
@export var JUMP_FORCE = -200
@export var dir = -1

@export var knockback_force := 200
@export var knockback_up_force := -140

var dead := false
var elementosRecebidos = []
var knockback := Vector2.ZERO

const MAX_ELEMENTOS = 2

const FOGO = "fogo"
const AGUA = "água"
const RAIO = "raio"
const PLANTA = "planta"

const tiposVariados = [
	FOGO,
	AGUA,
	RAIO,
	PLANTA
]

const BONUS_VAPORIZACAO = 2
const BONUS_ELETRICAMENTE_CARREGADO = 1
const BONUS_SOBRECARGA = 1

const DURACAO_ENRAIZAMENTO = 2.0
const DURACAO_QUEIMADURA = 2.0
const DURACAO_SOBRECARGA = 2.0
const DURACAO_ELETRIZACAO = 3.0

const DANO_QUEIMADURA = 1
const DANO_SOBRECARGA = 1
const DANO_CORRENTE = 1

const DISTANCIA_CORRENTE = 120.0

const FOGO_ICON = preload("res://placeholder/fogo.png")
const AGUA_ICON = preload("res://placeholder/agua.png")
const RAIO_ICON = preload("res://placeholder/raio.png")
const PLANTA_ICON = preload("res://placeholder/planta.png")

const ELEMENT_ICON_SIZE = Vector2(24, 24)
const ELEMENT_ICON_SPACING = 4.0
const ELEMENT_ICON_OFFSET = Vector2(0, -40)

var element_icons: Array[Sprite2D] = []

var imobilizado := false
var dano_aumentado := 1.0

var queimadura_timer := 0.0
var sobrecarga_timer := 0.0
var eletrizacao_timer := 0.0

var queimadura_tick_timer := 0.0
var sobrecarga_tick_timer := 0.0


func _ready() -> void:
	atualizar_icones_elementais()


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)

	if imobilizado:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if knockback.length() > 10:
		velocity.x = knockback.x
		knockback.x = move_toward(knockback.x, 0, 500 * delta)
	else:
		velocity.x = dir * Speed

	move_and_slide()

	if is_on_wall():
		dir *= -1


func receberAtaque(tipo):
	if tipo not in tiposVariados:
		return

	if tipo in elementosRecebidos:
		return

	if elementosRecebidos.size() >= MAX_ELEMENTOS:
		return

	elementosRecebidos.append(tipo)

	atualizar_icones_elementais()


func _aplicar_elemento(elemento, dano: int = 0, origem_x: float = 0.0) -> int:
	var tipo = ""

	match elemento:
		0:
			tipo = FOGO

		1:
			tipo = AGUA

		2:
			tipo = RAIO

		3:
			tipo = PLANTA

		_:
			return dano

	if tipo in elementosRecebidos:
		return dano

	if elementosRecebidos.size() >= MAX_ELEMENTOS:
		return dano

	elementosRecebidos.append(tipo)

	atualizar_icones_elementais()

	if elementosRecebidos.size() == 2:
		return ativar_reacao(dano, origem_x)

	return dano


func ativar_reacao(dano: int, origem_x: float) -> int:
	var elemento_1 = elementosRecebidos[0]
	var elemento_2 = elementosRecebidos[1]

	var elementos = [
		elemento_1,
		elemento_2
	]

	elementosRecebidos.clear()
	atualizar_icones_elementais()

	if FOGO in elementos and AGUA in elementos:
		return reacao_vaporizacao(dano)

	if AGUA in elementos and RAIO in elementos:
		return reacao_eletricamente_carregado(dano)

	if AGUA in elementos and PLANTA in elementos:
		return reacao_enraizamento(dano)

	if FOGO in elementos and PLANTA in elementos:
		return reacao_queimadura(dano)

	if FOGO in elementos and RAIO in elementos:
		return reacao_sobrecarga(dano)

	if RAIO in elementos and PLANTA in elementos:
		return reacao_eletrizacao(dano)

	return dano


func reacao_vaporizacao(dano: int) -> int:
	mostrar_reacao("VAPORIZAÇÃO")
	return dano + BONUS_VAPORIZACAO


func reacao_eletricamente_carregado(dano: int) -> int:
	mostrar_reacao("ELETRICAMENTE CARREGADO")
	aplicar_corrente_eletrica()
	return dano + BONUS_ELETRICAMENTE_CARREGADO


func reacao_enraizamento(dano: int) -> int:
	mostrar_reacao("ENRAIZAMENTO")

	imobilizado = true

	get_tree().create_timer(DURACAO_ENRAIZAMENTO).timeout.connect(
		finalizar_imobilizacao
	)

	return dano


func reacao_queimadura(dano: int) -> int:
	mostrar_reacao("QUEIMADURA")

	imobilizado = true
	queimadura_timer = DURACAO_QUEIMADURA
	queimadura_tick_timer = 0.0

	get_tree().create_timer(DURACAO_QUEIMADURA).timeout.connect(
		finalizar_queimadura
	)

	return dano


func reacao_sobrecarga(dano: int) -> int:
	mostrar_reacao("SOBRECARGA")

	sobrecarga_timer = DURACAO_SOBRECARGA
	sobrecarga_tick_timer = 0.0

	return dano + BONUS_SOBRECARGA


func reacao_eletrizacao(dano: int) -> int:
	mostrar_reacao("ELETRIZAÇÃO")

	dano_aumentado = 2.0
	eletrizacao_timer = DURACAO_ELETRIZACAO

	return dano


func processar_reacoes(delta: float) -> void:
	if queimadura_timer > 0:
		queimadura_timer -= delta
		queimadura_tick_timer -= delta

		if queimadura_tick_timer <= 0:
			queimadura_tick_timer = 0.5
			_dano(DANO_QUEIMADURA, global_position.x)

	if sobrecarga_timer > 0:
		sobrecarga_timer -= delta
		sobrecarga_tick_timer -= delta

		if sobrecarga_tick_timer <= 0:
			sobrecarga_tick_timer = 0.5
			_dano(DANO_SOBRECARGA, global_position.x)

	if eletrizacao_timer > 0:
		eletrizacao_timer -= delta

		if eletrizacao_timer <= 0:
			dano_aumentado = 1.0


func aplicar_corrente_eletrica() -> void:
	var inimigos = get_tree().get_nodes_in_group("Inimigo")

	for inimigo in inimigos:
		if inimigo == self:
			continue

		if not is_instance_valid(inimigo):
			continue

		if global_position.distance_to(inimigo.global_position) <= DISTANCIA_CORRENTE:
			if inimigo.has_method("receber_dano_corrente"):
				inimigo.receber_dano_corrente(DANO_CORRENTE)


func receber_dano_corrente(dano: int) -> void:
	_dano(dano, global_position.x)


func finalizar_imobilizacao() -> void:
	imobilizado = false


func finalizar_queimadura() -> void:
	queimadura_timer = 0.0


func atualizar_icones_elementais():
	for icon in element_icons:
		if is_instance_valid(icon):
			icon.queue_free()

	element_icons.clear()

	for i in range(elementosRecebidos.size()):
		var textura = obter_icone_elemento(elementosRecebidos[i])

		if textura == null:
			continue

		var icon = Sprite2D.new()

		icon.texture = textura
		icon.position = ELEMENT_ICON_OFFSET

		if elementosRecebidos.size() == 2:
			if i == 0:
				icon.position.x -= (ELEMENT_ICON_SIZE.x + ELEMENT_ICON_SPACING) / 2.0
			else:
				icon.position.x += (ELEMENT_ICON_SIZE.x + ELEMENT_ICON_SPACING) / 2.0

		icon.scale = Vector2(
			ELEMENT_ICON_SIZE.x / textura.get_width(),
			ELEMENT_ICON_SIZE.y / textura.get_height()
		)

		add_child(icon)
		element_icons.append(icon)


func obter_icone_elemento(tipo):
	match tipo:
		FOGO:
			return FOGO_ICON

		AGUA:
			return AGUA_ICON

		RAIO:
			return RAIO_ICON

		PLANTA:
			return PLANTA_ICON

	return null


func mostrar_reacao(nome_reacao: String) -> void:
	var label = Label.new()

	label.text = nome_reacao
	label.position = Vector2(-60, -75)
	label.z_index = 100

	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"position",
		Vector2(-60, -105),
		0.7
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.7
	)

	tween.finished.connect(label.queue_free)


func mostrar_dano(dano: int) -> void:
	var label = Label.new()

	label.text = str(dano)
	label.position = Vector2(-10, -55)
	label.z_index = 100

	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"position",
		Vector2(-10, -80),
		0.5
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.5
	)

	tween.finished.connect(label.queue_free)


func _dano(dano: int, origem_x: float):
	if dead:
		return

	dano = roundi(dano * dano_aumentado)

	Life -= dano

	mostrar_dano(dano)

	var direcao = sign(global_position.x - origem_x)

	knockback.x = direcao * knockback_force
	velocity.y = knockback_up_force

	if Life <= 0:
		die()


func die():
	dead = true
	queue_free()
