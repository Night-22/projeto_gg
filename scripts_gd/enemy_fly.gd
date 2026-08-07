extends CharacterBody2D
class_name Flying

@export var Life = 5
@export var Speed = 80
@export var dir = -1
@export var knockback_force := 200
@export var knockback_up_force := -100
#@export var use_gravity := false

var dead := false
var ataqueRecebidos = []
var knockback := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	#if use_gravity and not is_on_floor():
		#velocity += get_gravity() * delta
	
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

func _dano(dano: int, origem_x: float):
	if dead:
		return

	Life -= dano
	var direcao = sign(global_position.x - origem_x)
	knockback.x = direcao * knockback_force
	knockback.y = knockback_up_force
	velocity.y = knockback_up_force

	if Life <= 0:
		die()

func die():
	dead = true
	queue_free()
