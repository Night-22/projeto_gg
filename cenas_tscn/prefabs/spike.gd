extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	# Se estiver atacando para baixo e caindo,
	# não mata aqui. O pogo será tratado pelo area_entered.
	if body.looking_down and body.velocity.y > 0:
		return

	body.state_dead()


func _on_area_entered(area: Area2D) -> void:
	if area.name != "attackHitBox":
		return

	var player = area.get_parent()

	if !player.is_in_group("Player"):
		return

	print("SPIKE: attackHitBox detectado")
	print("looking_down:", player.looking_down)
	print("velocity.y:", player.velocity.y)

	if player.looking_down and player.velocity.y > 0:
		print("SPIKE: POGO!")

		player.fazer_pogo()
