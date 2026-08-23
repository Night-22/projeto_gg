extends Node2D

@onready var tilemap = get_node("colisao_esconder_medalhao/esconder_medalhao")

var tween_tilemap: Tween


func _ready() -> void:
	tilemap.visible = true
	tilemap.modulate.a = 1.0


func _on_colisao_esconder_medalhao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_tilemap(false)


func _on_colisao_esconder_medalhao_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	fade_tilemap(true)


func fade_tilemap(mostrar: bool) -> void:
	if tween_tilemap:
		tween_tilemap.kill()

	tween_tilemap = create_tween()

	tween_tilemap.set_trans(Tween.TRANS_SINE)
	tween_tilemap.set_ease(Tween.EASE_IN_OUT)

	var alpha_final := 1.0 if mostrar else 0.0
	var duracao := 0.35 if mostrar else 0.25

	tween_tilemap.tween_property(
		tilemap,
		"modulate:a",
		alpha_final,
		duracao
	)
