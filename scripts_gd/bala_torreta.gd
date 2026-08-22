extends Area2D

@export var velocidade := 200.0

var direcao := Vector2.RIGHT

func _physics_process(delta):
	global_position += direcao * velocidade * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.receber_dano(5, global_position.x)
		queue_free()
		return

	if body is TileMapLayer:
		queue_free()
