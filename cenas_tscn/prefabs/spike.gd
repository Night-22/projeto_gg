extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body.looking_down and body.velocity.y > 0:
		return

	body.state_dead()


func _on_area_entered(area: Area2D) -> void:
	if area.name != "attackHitBox":
		return

	var player = area.get_parent()

	if !player.is_in_group("Player"):
		return



	if player.looking_down and player.velocity.y > 0:
		

		player.fazer_pogo()
