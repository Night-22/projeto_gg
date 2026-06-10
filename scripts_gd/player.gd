extends CharacterBody2D

var Life = 3

@export var max_speed = 300.0
@export var acceleration = 3.0
@export var friction = 6.7

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var coyote_time_activated = false
@onready var coyote_timer: Timer = $coyoteTimer

var speed: float = 300.0
var jump_velocity = -500.0
var jump_count = 0

func _physics_process(delta: float) -> void:
	
	var jump_force = Input.get_action_strength("pulo")
	
	if is_on_floor():
		jump_count = 0
		coyote_time_activated = false
	
	if not is_on_floor():
		coyote_time_activated = true
		coyote_timer.start()
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("pulo") and (is_on_floor() or coyote_time_activated):
		if jump_count < 1:
			velocity.y = jump_velocity
			jump_count += 1
		else:
			return
		
	elif velocity.y < 0.0:
		if Input.is_action_just_released("pulo"):
			velocity.y = velocity.y * jump_force
	
	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")
	
	var velocity_weight = delta * (acceleration if direction else friction)
	
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * speed, velocity_weight)
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = lerp(velocity.x, 0.0, velocity_weight)
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



func _on_coyote_timer_timeout() -> void:
	coyote_time_activated = false
