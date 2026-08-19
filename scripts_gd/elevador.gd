extends Node2D

@onready var pos_2 = get_node("segundo_andar")
@onready var pos_1 = get_node("primeiro_andar")

@onready var plataforma: AnimatableBody2D = get_node("elevador")
var tween_botao: Tween
@onready var botao_subir = get_node("elevador/subir_plataforma")
@onready var botao_descer = get_node("elevador/descer_plataforma")

@onready var botao_ir_1 = get_node("ir_ate_primeiro_andar")
@onready var botao_ir_2 = get_node("ir_ate_segundo_andar")


var andar_atual = 1
var elevador_movendo = false

var posicao_inicial: Vector2
var posicao_destino: Vector2
var andar_destino: int

var tempo_movimento = 0.0
var duracao_movimento = 8.0


func _physics_process(delta: float) -> void:
	if not elevador_movendo:
		return

	tempo_movimento += delta

	var progresso = clamp(
		tempo_movimento / duracao_movimento,
		0.0,
		1.0
	)

	# movimento 
	var suavizado = smoothstep(0.0, 1.0, progresso)

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

	if andar_atual == 2:
		mover_elevador(pos_1.global_position, 1)


func _on_subir_plataforma_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	apertar_botao(botao_subir)

	if elevador_movendo:
		return

	if andar_atual == 1:
		mover_elevador(pos_2.global_position, 2)


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


func mover_elevador(posicao: Vector2, novo_andar: int) -> void:
	posicao_inicial = plataforma.global_position
	posicao_destino = posicao
	andar_destino = novo_andar

	tempo_movimento = 0.0
	elevador_movendo = true

func apertar_botao(botao: Node2D) -> void:
	if tween_botao:
		tween_botao.kill()

	botao.scale = Vector2.ONE

	tween_botao = create_tween()
	tween_botao.set_trans(Tween.TRANS_BACK)
	tween_botao.set_ease(Tween.EASE_OUT)

	tween_botao.tween_property(botao, "scale", Vector2.ONE * 0.7, 0.12)
	tween_botao.tween_property(botao, "scale", Vector2.ONE * 1.08, 0.08)
	tween_botao.tween_property(botao, "scale", Vector2.ONE, 0.15)
