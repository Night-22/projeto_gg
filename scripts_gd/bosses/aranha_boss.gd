extends Enemy
class_name AranhaBoss

signal chefe_derrotado

@export var parede_esquerda : StaticBody2D
@export var parede_direita : StaticBody2D

@export var player : CharacterBody2D

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

@onready var sprite = get_node("AnimatedSprite2D")

var teia_scene := preload("res://cenas_tscn/inimigos_tscn/bosses/teia_projetil.tscn")

@export var vida_maxima_boss := 200
@export var numero_pernas := 8


@export var limite_esquerdo := -100
@export var limite_direito := 200.0
@export var distancia_ate_o_chao := 170.0


@export var velocidade_movimento := 140.0
@export var margem_arena := 1.0


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

var ataques_porradao: Array[String] = [
	"pata_baixo_esquerda",
	"pata_cima_esquerda",
	"pata_medio_esquerda",
	"pata_baixo_direita",
	"pata_cima_direita",
	"pata_medio_direita"
]

var _colisao_porradao_ativa := false

@onready var hitbox_esquerda: Area2D = $Pata_Porrada_esquerda
@onready var hitbox_direita: Area2D = $Pata_porrada_direita

@export var colisao_esquerda : CollisionShape2D
@export var colisao_direita : CollisionShape2D


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

@export var aceleracao := 500.0
@export var desaceleracao := 700.0
@export var velocidade_perseguicao := 220.0



func tocar_animacao(nome_animacao: String) -> void:
	sprite.play(nome_animacao)


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




	if estado_atual != Estado.ATAQUE_MORDIDA:
		global_position.y = altura_suspensa_global
	move_and_slide()

	if estado_atual == Estado.ANDANDO_LADOS:
		for i in get_slide_collision_count():
			var colisao := get_slide_collision(i)
			var collider := colisao.get_collider()

			if collider == parede_esquerda:
				direcao_movimento = 1
				sprite.flip_h = false
				break

			elif collider == parede_direita:
				direcao_movimento = -1
				sprite.flip_h = true
				break


func _trocar_estado(novo: int) -> void:
	estado_atual = novo

	match novo:
		Estado.IDLE:
			modulate = Color.WHITE
			tocar_animacao("idle")

			estado_timer = randf_range(tempo_idle_min, tempo_idle_max)

		Estado.ANDANDO_LADOS:
			direcao_movimento = [-1, 1].pick_random()
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
	tocar_animacao("idle")

	velocity.x = move_toward(
		velocity.x,
		0.0,
		desaceleracao * delta
	)

	velocity.y = 0

	estado_timer -= delta

	if estado_timer <= 0:
		_escolher_proxima_acao()
		
func _estado_andando_lados(delta: float) -> void:
	tocar_animacao("andando")

	var velocidade_alvo := direcao_movimento * velocidade_movimento

	velocity.x = move_toward(
		velocity.x,
		velocidade_alvo,
		aceleracao * delta
	)

	velocity.y = 0

	sprite.flip_h = velocity.x < 0

	estado_timer -= delta

	if estado_timer <= 0:
		_trocar_estado(Estado.IDLE)

func _estado_indo_para_centro(delta: float) -> void:
	tocar_animacao("andando")

	var centro_x := (parede_esquerda.global_position.x + parede_direita.global_position.x) / 2.0
	var direcao := signf(centro_x - global_position.x)

	var velocidade_alvo := direcao * velocidade_movimento

	velocity.x = move_toward(
		velocity.x,
		velocidade_alvo,
		aceleracao * delta
	)

	velocity.y = 0

	if abs(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0

	if abs(centro_x - global_position.x) < 4.0:
		velocity.x = 0
		_trocar_estado(Estado.PREPARANDO_PORRADAO)

func _estado_perseguindo(delta: float) -> void:
	if jogador == null or not is_instance_valid(jogador):
		velocity.x = move_toward(velocity.x, 0.0, desaceleracao * delta)
		
		if abs(velocity.x) < 1.0:
			velocity.x = 0.0
		
		_trocar_estado(Estado.IDLE)
		return

	tocar_animacao("andando")

	var direcao := signf(jogador.global_position.x - global_position.x)

	var velocidade_alvo := direcao * velocidade_perseguicao

	velocity.x = move_toward(
		velocity.x,
		velocidade_alvo,
		aceleracao * delta
	)

	velocity.y = 0

	if abs(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0

	estado_timer -= delta

	if estado_timer <= 0:
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


var ataques_esquerda: Array[String] = [
	"pata_baixo_esquerda",
	"pata_cima_esquerda",
	"pata_medio_esquerda"
]

var ataques_direita: Array[String] = [
	"pata_baixo_direita",
	"pata_cima_direita",
	"pata_medio_direita"
]


func _estado_porradao(_delta: float) -> void:
	velocity = Vector2.ZERO


func _iniciar_porradao() -> void:
	if _porradao_em_andamento:
		return

	_porradao_em_andamento = true
	await _executar_ataque_porradao()


func _executar_ataque_porradao() -> void:
	var ataques: Array[String]

	# desliga as duas
	colisao_esquerda.set_deferred("disabled", true)
	colisao_direita.set_deferred("disabled", true)

	await get_tree().physics_frame

	# escolhe o lado
	if randi() % 2 == 0:
		ataques = ataques_esquerda
	else:
		ataques = ataques_direita

	# faz os 3 ataques
	for ataque in ataques:
		if dead:
			break
		
		sprite.flip_h = false
		await _executar_animacao_porradao(ataque)

	# desliga tudo
	colisao_esquerda.set_deferred("disabled", true)
	colisao_direita.set_deferred("disabled", true)

	await get_tree().physics_frame

	_porradao_em_andamento = false

	if not dead:
		_trocar_estado(Estado.IDLE)


func _executar_animacao_porradao(ataque: String) -> void:
	var hitbox_ativa: CollisionShape2D

	# escolhe a hitbox
	if ataque in ataques_esquerda:
		hitbox_ativa = colisao_esquerda
	elif ataque in ataques_direita:
		hitbox_ativa = colisao_direita
	else:
		print("ataque invalido: ", ataque)
		return

	# desliga as duas
	colisao_esquerda.set_deferred("disabled", true)
	colisao_direita.set_deferred("disabled", true)

	await get_tree().physics_frame

	if dead:
		return

	# deixa a animacao anterior parar
	sprite.stop()

	# toca a animacao escolhida
	sprite.play(ataque)

	# espera o sprite atualizar
	await get_tree().process_frame

	# garante que comecou no frame 0
	sprite.frame = 0

	print("ataque escolhido: ", ataque)
	print("animacao atual: ", sprite.animation)

	# confere se a animacao realmente foi trocada
	if sprite.animation != StringName(ataque):
		print("erro na animacao: esperado ", ataque, " mas esta ", sprite.animation)
		return

	# espera o frame de impacto
	while sprite.frame < 4:
		await get_tree().process_frame

		if dead:
			colisao_esquerda.set_deferred("disabled", true)
			colisao_direita.set_deferred("disabled", true)
			await get_tree().physics_frame
			return

	# desliga as duas antes de ligar a certa
	colisao_esquerda.set_deferred("disabled", true)
	colisao_direita.set_deferred("disabled", true)

	await get_tree().physics_frame

	# liga a hitbox correta
	hitbox_ativa.set_deferred("disabled", false)
	
	player.tremer_camera(10, 0.5)
	
	await get_tree().physics_frame

	# da dano em quem ja estiver dentro
	_dar_dano_porradao(hitbox_ativa.get_parent())

	print("animacao atual no impacto: ", sprite.animation)
	print("hitbox ativa: ", hitbox_ativa.get_path())
	print("esquerda ativa: ", !colisao_esquerda.disabled)
	print("direita ativa: ", !colisao_direita.disabled)

	# espera a animacao acabar
	await sprite.animation_finished

	# desliga tudo
	colisao_esquerda.set_deferred("disabled", true)
	colisao_direita.set_deferred("disabled", true)

	await get_tree().physics_frame

	print("ataque terminou: ", ataque)


func _dar_dano_porradao(hitbox: Area2D) -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("receber_dano"):
			body.receber_dano(dano_porradao, global_position.x)


func _estado_ataque_teia(_delta: float) -> void:
	velocity = Vector2.ZERO


func _iniciar_ataque_teia() -> void:
	tocar_animacao("mordendo")

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
	tocar_animacao("mordendo")

	var y_original := global_position.y
	var y_alvo := chao_y - 40.0

	if mordida_hitbox:
		mordida_hitbox.monitoring = true

	var tween := create_tween()
	tween.tween_property(self, "global_position:y", y_alvo, tempo_descida_mordida)
	player.tremer_camera(5, tempo_descida_mordida)
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


#func _on_pata_porrada_esquerda_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player") and body.has_method("receber_dano"):
		#body.receber_dano(dano_porradao, global_position.x)
#
#
#
#
#func _on_pata_porrada_direita_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player") and body.has_method("receber_dano"):
		#body.receber_dano(dano_porradao, global_position.x)
