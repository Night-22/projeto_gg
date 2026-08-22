extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.receber_dano(999, global_position.x)
