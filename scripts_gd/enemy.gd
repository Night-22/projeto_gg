extends CharacterBody2D
class_name Enemy

@export var Life = 5
@export var Speed = 60
@export var JUMP_FORCE = -200
@export var dir = -1

@export var patrulha := true
@export var pratulha_time := 2.0

var dead := false
var patrol_timer := 0.0

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if patrulha:
		patrol_timer += delta
	
		if patrol_timer >= pratulha_time:
			patrol_timer = 0.0
			dir *= -1
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = dir * Speed
	move_and_slide()

func _dano(dano: int):
	if dead:
		return
	Life -= dano
	if Life <= 0:
		die()

func die():
	dead = true
	queue_free()
