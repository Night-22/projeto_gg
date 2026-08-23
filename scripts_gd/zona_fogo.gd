extends Node2D

@onready var fundo_sala_medalhao = get_node("fundo_da_sala_medalhao")

var tween_fundo: Tween


func _ready() -> void:
	fundo_sala_medalhao.visible = true
	fundo_sala_medalhao.modulate.a = 1.0

	var player = get_tree().get_first_node_in_group("Player")

	if player != null:
		player.dentro_da_zona_fogo = true


func _physics_process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	var esta_na_agua := false

	
	for agua in get_tree().get_nodes_in_group("agua"):
		if agua is Area2D:
			if agua.overlaps_body(player):
				esta_na_agua = true
				break

	if esta_na_agua:
		
		player.dentro_da_agua = true
		player.dentro_da_zona_fogo = false
		
	else:
		player.sair_da_agua()
		player.dentro_da_agua = false
		player.dentro_da_zona_fogo = true


func _on_area_sala_medalhao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_fundo(false)


func _on_area_sala_medalhao_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_fundo(true)


func fade_fundo(mostrar: bool) -> void:
	if tween_fundo:
		tween_fundo.kill()

	tween_fundo = create_tween()

	tween_fundo.set_trans(Tween.TRANS_SINE)
	tween_fundo.set_ease(Tween.EASE_IN_OUT)

	var alpha_final := 1.0 if mostrar else 0.0
	var duracao := 0.35 if mostrar else 0.25

	tween_fundo.tween_property(
		fundo_sala_medalhao,
		"modulate:a",
		alpha_final,
		duracao
	)
