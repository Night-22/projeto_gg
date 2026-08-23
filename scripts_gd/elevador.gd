extends Node2D

@export_range(1, 5, 1) var andar_inicial: int = 1

@onready var pos_1 = get_node("primeiro_andar")
@onready var pos_2 = get_node("segundo_andar")
@onready var pos_3 = get_node("terceiro_andar")
@onready var pos_4 = get_node("quarto_andar")
@onready var pos_5 = get_node("quinto_andar")

@onready var plataforma: AnimatableBody2D = get_node("elevador")

var tween_botao: Tween

@onready var botao_subir = get_node("elevador/subir_plataforma")
@onready var botao_descer = get_node("elevador/descer_plataforma")

@onready var botao_ir_1 = get_node("ir_ate_primeiro_andar")
@onready var botao_ir_2 = get_node("ir_ate_segundo_andar")
@onready var botao_ir_3 = get_node_or_null("ir_ate_terceiro_andar")
@onready var botao_ir_4 = get_node("ir_ate_quarto_andar")
@onready var botao_ir_5 = get_node("ir_ate_quinto_andar")


var andar_atual: int = 1
var elevador_movendo: bool = false

var posicao_inicial: Vector2
var posicao_destino: Vector2
var andar_destino: int

var tempo_movimento: float = 0.0
var duracao_movimento: float = 8.0


func elevador_para_terceiro_instantaneo() -> void:
	plataforma.global_position = $elevador_fogo.global_position
	
	andar_atual = 3
	elevador_movendo = false
	tempo_movimento = 0.0
	posicao_inicial = plataforma.global_position
	posicao_destino = plataforma.global_position
	andar_destino = 3


func _physics_process(delta: float) -> void:
	if not elevador_movendo:
		return

	tempo_movimento += delta

	var progresso = clamp(
		tempo_movimento / duracao_movimento,
		0.0,
		1.0
	)

	var suavizado := smoothstep(0.0, 1.0, progresso)

	plataforma.global_position = posicao_inicial.lerp(
		posicao_destino,
		suavizado
	)

	if progresso >= 1.0:
		plataforma.global_position = posicao_destino
		elevador_movendo = false
		andar_atual = andar_destino


func _on_descer_plataforma_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_descer)

	if elevador_movendo:
		return

	match andar_atual:
		5:
			mover_elevador(pos_4.global_position, 4)

		4:
			mover_elevador(pos_3.global_position, 3)

		3:
			mover_elevador(pos_2.global_position, 2)

		2:
			mover_elevador(pos_1.global_position, 1)


func _on_subir_plataforma_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_subir)

	if elevador_movendo:
		return

	match andar_atual:
		1:
			mover_elevador(pos_2.global_position, 2)

		2:
			mover_elevador(pos_3.global_position, 3)

		3:
			mover_elevador(pos_4.global_position, 4)

		4:
			mover_elevador(pos_5.global_position, 5)


func _on_ir_ate_primeiro_andar_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_ir_1)

	if elevador_movendo:
		return

	if andar_atual != 1:
		mover_elevador(pos_1.global_position, 1)


func _on_ir_ate_segundo_andar_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_ir_2)

	if elevador_movendo:
		return

	if andar_atual != 2:
		mover_elevador(pos_2.global_position, 2)


func _on_ir_ate_terceiro_andar_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	if botao_ir_3:
		apertar_botao(botao_ir_3)

	if elevador_movendo:
		return

	if andar_atual != 3:
		mover_elevador(pos_3.global_position, 3)


func _on_ir_ate_quarto_andar_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_ir_4)

	if elevador_movendo:
		return

	if andar_atual != 4:
		mover_elevador(pos_4.global_position, 4)


func _on_ir_ate_quinto_andar_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_ir_5)

	if elevador_movendo:
		return

	if andar_atual != 5:
		mover_elevador(pos_5.global_position, 5)


func mover_elevador(posicao: Vector2, novo_andar: int) -> void:
	posicao_inicial = plataforma.global_position
	posicao_destino = posicao
	andar_destino = novo_andar

	tempo_movimento = 0.0
	elevador_movendo = true


func apertar_botao(botao: Node2D) -> void:
	if botao == null:
		return

	if tween_botao:
		tween_botao.kill()

	botao.scale = Vector2.ONE

	tween_botao = create_tween()
	tween_botao.set_trans(Tween.TRANS_BACK)
	tween_botao.set_ease(Tween.EASE_OUT)

	tween_botao.tween_property(
		botao,
		"scale",
		Vector2.ONE * 0.7,
		0.12
	)

	tween_botao.tween_property(
		botao,
		"scale",
		Vector2.ONE * 1.08,
		0.08
	)

	tween_botao.tween_property(
		botao,
		"scale",
		Vector2.ONE,
		0.15
	)
func _ready() -> void:


	# RETORNO DA ZONA DE FOGO
	if Transicao.voltando_da_zona_fogo:

		plataforma.global_position = $elevador_fogo.global_position

		andar_atual = 3
		andar_destino = 3
		elevador_movendo = false
		tempo_movimento = 0.0

		posicao_inicial = plataforma.global_position
		posicao_destino = plataforma.global_position

		
		Transicao.voltando_da_zona_fogo = false

		return



	andar_atual = andar_inicial

	match andar_inicial:
		1:
			plataforma.global_position = pos_1.global_position

		2:
			plataforma.global_position = pos_2.global_position

		3:
			plataforma.global_position = pos_3.global_position

		4:
			plataforma.global_position = pos_4.global_position

		5:
			plataforma.global_position = pos_5.global_position
