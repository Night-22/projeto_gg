extends Node2D

@export var velocidade = 7
@export var aceleracao = 4
@export var velocidade_maxima = 15.0


func _physics_process(delta: float) -> void:
	velocidade += aceleracao * delta
	velocidade = min(velocidade, velocidade_maxima)

	position.y -= velocidade * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.resetar_tempo_respirar()
		queue_free()


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1)
	await get_tree().create_timer(1).timeout
	queue_free()
