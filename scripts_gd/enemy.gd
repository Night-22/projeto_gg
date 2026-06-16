extends CharacterBody2D
class_name Enemy

@export var Life = 5
@export var Speed = 60
@export var JUMP_FORCE = -200
@export var dir = -1

var dead := false

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = dir * Speed
	move_and_slide()
	
	if is_on_wall():
		dir *= -1

func _dano(dano: int):
	if dead:
		return
	
	Life -= dano
	
	if Life <= 0:
		die()

func die():
	dead = true
	queue_free()
