extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not body.dentro_da_agua:
			body.dentro_da_zona_fogo = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.dentro_da_zona_fogo = false
