extends Enemy
class_name Flying

func _physics_process(delta: float) -> void:
	if dead:
		return

	if knockback.length() > 10:
		velocity.x = knockback.x
		velocity.y = knockback.y
		knockback = knockback.move_toward(Vector2.ZERO, 500 * delta)
	else:
		velocity.x = dir * Speed
		velocity.y = 0

	move_and_slide()

	if is_on_wall():
		dir *= -1
