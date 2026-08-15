extends Enemy

@export var walk_speed := 40

@export var mini_jump_force := -120.0
@export var mini_jump_speed := 40.0

@export var leap_speed := 140

@export var leap_force := -280
@export var jump_cooldown := 0.8
@export var patrol_time := 2.0


@onready var area: Area2D = $percepcao
@onready var timer: Timer = $Timer
@onready var patrol_timer: Timer = $PatrolTimer


var player: Node2D = null
var can_jump := true
var jumping := false


func _ready():
	patrol_timer.wait_time = patrol_time
	patrol_timer.start()

func _physics_process(delta):
	if dead:
		return
	
	if player == null:
		
		Speed = mini_jump_speed
		if can_jump and is_on_floor():
		
			jumping = true
			can_jump = false
			
			Speed = mini_jump_speed
			velocity.y = mini_jump_force
			
			timer.wait_time = jump_cooldown
			timer.start()

	
	else:
		dir = sign(player.global_position.x - global_position.x)
		
		if !jumping:
			Speed = 0
			
		if can_jump and is_on_floor():
			
			jumping = true
			can_jump = false
			
			Speed = leap_speed
			velocity.y = leap_force
			
			timer.wait_time = jump_cooldown
			timer.start()
	
	if jumping:
		Speed = leap_speed
		
		if is_on_floor() and velocity.y >= 0:
			jumping = false
			Speed = 0
	super._physics_process(delta)


func _on_timer_timeout():
	can_jump = true

func _on_patrol_timer_timeout():
	if player == null:
		dir *= -1
		patrol_timer.start()

func _on_percepcao_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		patrol_timer.stop()

func _on_percepcao_body_exited(body):
	if body == player:
		player = null
