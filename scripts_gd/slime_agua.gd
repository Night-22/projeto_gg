extends Enemy

@export var walk_speed: float = 40.0

@export var mini_jump_force: float = -120.0
@export var mini_jump_speed: float = 40.0

@export var leap_speed: float = 140.0
@export var leap_force: float = -280.0

@export var jump_cooldown: float = 0.8
@export var patrol_time: float = 2.0
@export var limite_altura: float = 30.0

@onready var area: Area2D = $percepcao
@onready var timer: Timer = $Timer
@onready var patrol_timer: Timer = $PatrolTimer

var player: Node2D = null

var can_jump: bool = true
var jumping: bool = false
var chasing: bool = false


func _ready() -> void:
	patrol_timer.wait_time = patrol_time
	patrol_timer.start()

	timer.wait_time = jump_cooldown


func _physics_process(delta: float) -> void:
	if dead:
		return

	var player_dentro_da_altura: bool = false

	if player != null and is_instance_valid(player):
		var diferenca_y: float = abs(player.global_position.y - global_position.y)
		player_dentro_da_altura = diferenca_y <= limite_altura

	if player != null and is_instance_valid(player) and player_dentro_da_altura:
		chasing = true
		patrol_timer.stop()

		var nova_direcao: float = sign(player.global_position.x - global_position.x)

		if nova_direcao != 0.0:
			dir = nova_direcao

		if can_jump and is_on_floor():
			iniciar_pulo_perseguicao()
	else:
		chasing = false

		if can_jump and is_on_floor():
			iniciar_mini_pulo()

	super._physics_process(delta)


func iniciar_mini_pulo() -> void:
	jumping = true
	can_jump = false

	Speed = mini_jump_speed
	velocity.y = mini_jump_force

	timer.start()


func iniciar_pulo_perseguicao() -> void:
	jumping = true
	can_jump = false

	Speed = leap_speed
	velocity.y = leap_force

	timer.start()


func _on_timer_timeout() -> void:
	can_jump = true


func _on_patrol_timer_timeout() -> void:
	if player == null or !is_instance_valid(player):
		dir *= -1

	patrol_timer.start()


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		patrol_timer.stop()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		chasing = false
		patrol_timer.start()
