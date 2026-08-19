extends CharacterBody2D
class_name Enemy

enum ElementoNativo {
	SEM_ELEMENTO,
	AGUA,
	FOGO,
	RAIO,
	PLANTA
}


@export var Life = 50
@export var Speed = 60
@export var JUMP_FORCE = -200
@export var dir = -1
@export var elemento_nativo: ElementoNativo = ElementoNativo.SEM_ELEMENTO
@export var chance_drop_alma := 1.0

@export var knockback_force := 100
@export var knockback_up_force := -120
@export var knockback_ataque := 30

var dead := false
var elementosRecebidos = []
var knockback := Vector2.ZERO

var max_elementos = 2

var fogo = "fogo"
var agua = "água"
var raio = "raio"
var planta = "planta"

var tiposVariados = [
	fogo,
	agua,
	raio,
	planta
]

var duracao_enraizamento = 2.0
var duracao_queimadura = 2.0
var duracao_sobrecarga = 2.0
var duracao_eletrizacao = 3.0

var dano_queimadura = 1
var dano_sobrecarga = 1
var dano_corrente = 1

var distancia_corrente = 120.0

var fogo_icon = preload("res://placeholder/fogo.png")
var agua_icon = preload("res://placeholder/agua.png")
var raio_icon = preload("res://placeholder/raio.png")
var planta_icon = preload("res://placeholder/planta.png")

var alma_scene = preload("res://cenas_tscn/itens/alma_elemental.tscn")

var element_icon_size = Vector2(24, 24)
var element_icon_spacing = 4.0
var element_icon_offset = Vector2(0, -40)

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


func obter_elemento_nativo() -> int:
	return elemento_nativo


func receberAtaque(tipo):
	if tipo not in tiposVariados:
		return

	if tipo in elementosRecebidos:
		return

	if elementosRecebidos.size() >= max_elementos:
		return

	elementosRecebidos.append(tipo)

	atualizar_icones_elementais()


func _aplicar_elemento(elemento, dano: int = 0, origem_x: float = 0.0) -> int:
	var tipo = ""

	match elemento:
		0:
			tipo = fogo

		1:
			tipo = agua

		2:
			tipo = raio

		3:
			tipo = planta

		_:
			return dano

	if tipo in elementosRecebidos:
		return dano

	if elementosRecebidos.size() >= max_elementos:
		return dano

	elementosRecebidos.append(tipo)

	atualizar_icones_elementais()

	if elementosRecebidos.size() == 2:
		return ativar_reacao(dano, origem_x)

	return dano


func ativar_reacao(dano, _origem_x: float) -> int:
	var elemento_1 = elementosRecebidos[0]
	var elemento_2 = elementosRecebidos[1]

	var elementos = [
		elemento_1,
		elemento_2
	]

	elementosRecebidos.clear()
	atualizar_icones_elementais()

	if fogo in elementos and agua in elementos:
		return reacao_vaporizacao(dano)

	if agua in elementos and raio in elementos:
		return reacao_eletricamente_carregado(dano)

	if agua in elementos and planta in elementos:
		return reacao_enraizamento(dano)

	if fogo in elementos and planta in elementos:
		return reacao_queimadura(dano)

	if fogo in elementos and raio in elementos:
		return reacao_sobrecarga(dano)

	if raio in elementos and planta in elementos:
		return reacao_eletrizacao(dano)

	return dano


func reacao_vaporizacao(dano: int) -> int:
	mostrar_reacao("VAPORIZAÇÃO")
	return roundi(dano * 2.0)


func reacao_eletricamente_carregado(dano: int) -> int:
	mostrar_reacao("ELETRICAMENTE CARREGADO")
	aplicar_corrente_eletrica()
	return roundi(dano * 1.5)


func reacao_enraizamento(dano: int) -> int:
	mostrar_reacao("ENRAIZAMENTO")

	imobilizado = true

	get_tree().create_timer(duracao_enraizamento).timeout.connect(
		finalizar_imobilizacao
	)

	return dano


func reacao_queimadura(dano: int) -> int:
	mostrar_reacao("QUEIMADURA")

	imobilizado = true
	queimadura_timer = duracao_queimadura
	queimadura_tick_timer = 0.0

	get_tree().create_timer(duracao_queimadura).timeout.connect(
		finalizar_queimadura
	)

	return dano


func reacao_sobrecarga(dano: int) -> int:
	mostrar_reacao("SOBRECARGA")

	sobrecarga_timer = duracao_sobrecarga
	sobrecarga_tick_timer = 0.0

	return roundi(dano * 1.5)


func reacao_eletrizacao(dano: int) -> int:
	mostrar_reacao("ELETRIZAÇÃO")

	dano_aumentado = 2.0
	eletrizacao_timer = duracao_eletrizacao

	return dano


func processar_reacoes(delta: float) -> void:
	if queimadura_timer > 0:
		queimadura_timer -= delta
		queimadura_tick_timer -= delta

		if queimadura_tick_timer <= 0:
			queimadura_tick_timer = 0.5
			_dano(dano_queimadura, global_position.x)

	if sobrecarga_timer > 0:
		sobrecarga_timer -= delta
		sobrecarga_tick_timer -= delta

		if sobrecarga_tick_timer <= 0:
			sobrecarga_tick_timer = 0.5
			_dano(dano_sobrecarga, global_position.x)

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

		if global_position.distance_to(inimigo.global_position) <= distancia_corrente:
			if inimigo.has_method("receber_dano_corrente"):
				inimigo.receber_dano_corrente(dano_corrente)


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
		icon.position = element_icon_offset

		if elementosRecebidos.size() == 2:
			if i == 0:
				icon.position.x -= (element_icon_size.x + element_icon_spacing) / 2.0
			else:
				icon.position.x += (element_icon_size.x + element_icon_spacing) / 2.0

		icon.scale = Vector2(
			element_icon_size.x / textura.get_width(),
			element_icon_size.y / textura.get_height()
		)

		add_child(icon)
		element_icons.append(icon)


func obter_icone_elemento(tipo):
	match tipo:
		fogo:
			return fogo_icon

		agua:
			return agua_icon

		raio:
			return raio_icon

		planta:
			return planta_icon

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
	var particula = preload("res://particles/explosion.tscn").instantiate()

	if direcao == 0:
		direcao = -1

	particula.global_position = global_position
	get_parent().add_child(particula)

	knockback.x = direcao * knockback_force
	velocity.y = knockback_up_force

	if Life <= 0:
		die()


func die():
	if dead:
		return

	dead = true
	call_deferred("dropar_almas")
	call_deferred("queue_free")


func dropar_almas() -> void:
	if randf() > chance_drop_alma:
		return

	if elemento_nativo == ElementoNativo.SEM_ELEMENTO:
		dropar_almas_sem_elemento()
		return

	var quantidade = randi_range(2, 5)

	for i in range(quantidade):
		criar_alma(elemento_nativo)


func dropar_almas_sem_elemento() -> void:
	var quantidade = randi_range(1, 2)

	for i in range(quantidade):
		var elemento = randi_range(
			ElementoNativo.AGUA,
			ElementoNativo.PLANTA
		)

		criar_alma(elemento)


func criar_alma(elemento: ElementoNativo) -> void:
	var alma = alma_scene.instantiate()

	get_parent().add_child(alma)

	alma.global_position = global_position

	var tipo_alma = converter_elemento_para_alma(elemento)

	alma.configurar(tipo_alma)

	var direcao = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, -0.2)
	).normalized()

	alma.position += direcao * randf_range(10.0, 30.0)


func converter_elemento_para_alma(elemento: ElementoNativo) -> int:
	match elemento:
		ElementoNativo.AGUA:
			return 0

		ElementoNativo.FOGO:
			return 1

		ElementoNativo.RAIO:
			return 2

		ElementoNativo.PLANTA:
			return 3

	return 0
