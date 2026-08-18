extends Bolha
class_name Bolha_de_ar

@onready var cena_bolha_de_ar = preload("res://cenas_tscn/bolha_de_ar.tscn")


func _on_timer_timeout() -> void:
	var bolha = cena_bolha_de_ar.instantiate()
	add_child(bolha)

	bolha.position = Vector2.ZERO
	bolha.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(bolha, "modulate:a", 1.0, 0.5)
