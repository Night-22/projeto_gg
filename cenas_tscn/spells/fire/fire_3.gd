extends Node2D

var duration = 3.0
var cooldown = 30.0
var mana_cost = 30.0

var cooldown_timer: Timer
var player = null
var fire_position := Vector2.ZERO

var fire_scene = preload("res://cenas_tscn/spells/fire/fire_3_ground.tscn")

@onready var delay_timer: Timer = $DelayTimer


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)

	delay_timer.one_shot = true


func use(owner_player) -> void:
	if !cooldown_timer.is_stopped():
		return

	if owner_player.Mana < mana_cost:
		return

	player = owner_player

	player.Mana -= mana_cost

	fire_position = player.global_position + Vector2(
		35 * player.last_direction,
		20
	)

	delay_timer.start(1.0)


func criar_fogo() -> void:
	var fire = fire_scene.instantiate()

	get_tree().current_scene.add_child(fire)

	fire.global_position = fire_position

	if fire.has_method("iniciar"):
		fire.iniciar(duration)

	cooldown_timer.start()

	player = null


func _on_delay_timer_timeout() -> void:
	criar_fogo()


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
