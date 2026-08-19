extends Area2D

@onready var _colisao: CollisionShape2D = $CollisionShape2D


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body.has_method("travar_camera"):
		body.travar_camera(area_de_confinamento(), self)


func _on_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body.has_method("destravar_camera"):
		body.destravar_camera(self)


func area_de_confinamento() -> Rect2:
	var forma := _colisao.shape

	var tamanho := Vector2(20, 20)

	if forma is RectangleShape2D:
		tamanho = forma.size

	var tamanho_global := Vector2.ZERO

	for i in 2:
		tamanho_global[i] = tamanho[i] * _colisao.global_scale[i]

	var centro_global: Vector2 = _colisao.global_position

	return Rect2(
		centro_global - tamanho_global / 2.0,
		tamanho_global
	)
