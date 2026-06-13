extends Enemy

@export var walk_speed := 60
@export var leap_speed := 180
@export var leap_force := -450

@onready var area: Area2D = $percepcao
@onready var timer: Timer = $Timer

var player: Node2D = null
var can_jump := true

func _physics_process(delta):
	if dead:
		return
	Speed = walk_speed
	
	if player != null and can_jump and is_on_floor():
		if player.global_position.x > global_position.x:
			dir = 1
		else:
			dir = -1
		
		velocity.x = dir * leap_speed
		velocity.y = leap_force
		
		can_jump = false
		timer.start()
	
	
	if player != null:
		patrulha = false
	else:
		patrulha = true
	super._physics_process(delta)

func _on_timer_timeout():
	can_jump = true

func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
