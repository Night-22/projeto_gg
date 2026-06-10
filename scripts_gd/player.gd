extends CharacterBody2D

var Life = 3


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.play("idle")
	move_and_slide()
	
	if Life <= 0 :
		die()

func die():
	queue_free()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigo"):
		Life -= 1
		print(Life)
