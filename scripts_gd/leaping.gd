extends Enemy

@export var walk_speed := 60
@export var leap_speed := 220
@export var leap_force := -380

@onready var area: Area2D = $percepcao
@onready var timer: Timer = $Timer

var player: Node2D = null
var can_jump := true
var jumping := false

func _physics_process(delta):
	if dead:
		return

	if jumping:
		Speed = leap_speed
	else:
		Speed = walk_speed

	if player != null and can_jump and is_on_floor():
		dir = sign(player.global_position.x - global_position.x)

		jumping = true
		velocity.y = leap_force

		can_jump = false
		timer.start()

	if jumping and is_on_floor() and velocity.y >= 0:
		jumping = false

	super._physics_process(delta)

func _on_timer_timeout():
	can_jump = true

func _on_percepcao_body_entered(body):
	if body.is_in_group("Player"):
		player = body

func _on_percepcao_body_exited(body):
	if body == player:
		player = null
