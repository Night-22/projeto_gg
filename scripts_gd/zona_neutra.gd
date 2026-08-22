extends Node2D


@onready var predio_direita = $parede_de_fora_predio_direita
@onready var predio_esquerda = $parede_de_fora_predio_esquerda

var tween_direita: Tween
var tween_esquerda: Tween


func _ready() -> void:
	predio_direita.visible = true
	predio_esquerda.visible = true

	predio_direita.modulate.a = 1.0
	predio_esquerda.modulate.a = 1.0


func _on_parede_de_fora_predio_direita_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_predio(predio_direita, false, tween_direita)


func _on_parede_de_fora_predio_direita_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_predio(predio_direita, true, tween_direita)


func _on_parede_de_fora_predio_esquerda_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_predio(predio_esquerda, false, tween_esquerda)


func _on_parede_de_fora_predio_esquerda_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_predio(predio_esquerda, true, tween_esquerda)


func fade_predio(predio: CanvasItem, mostrar: bool, tween_atual: Tween) -> void:
	if tween_atual:
		tween_atual.kill()

	var novo_tween := create_tween()

	novo_tween.set_trans(Tween.TRANS_SINE)
	novo_tween.set_ease(Tween.EASE_IN_OUT)

	var alpha_final := 1.0 if mostrar else 0.0
	var duracao := 0.35 if mostrar else 0.25

	novo_tween.tween_property(
		predio,
		"modulate:a",
		alpha_final,
		duracao
	)

	if predio == predio_direita:
		tween_direita = novo_tween
	else:
		tween_esquerda = novo_tween


func _on_area_botao_subir_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
