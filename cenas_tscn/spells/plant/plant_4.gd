extends Node2D

var cooldown = 30.0
var mana_cost = 35

var cooldown_timer: Timer
var spawn_timer: Timer

var spawn_position := Vector2.ZERO
var direction := 1

var current_vine = 0

var vine_scenes = [
	preload("res://cenas_tscn/spells/plant/plant_4_small.tscn"),
	preload("res://cenas_tscn/spells/plant/plant_4_medium.tscn"),
	preload("res://cenas_tscn/spells/plant/plant_4_large.tscn")
]

var vine_offsets = [
	Vector2(60, 0),
	Vector2(130, 0),
	Vector2(220, 0)
]


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)

	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.wait_time = 0.4
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)


func use(owner_player) -> void:
	if !cooldown_timer.is_stopped():
		return

	if owner_player.Mana < mana_cost:
		return

	owner_player.Mana -= mana_cost

	spawn_position = owner_player.global_position
	direction = owner_player.last_direction

	current_vine = 0

	cooldown_timer.start()

	criar_proxima_vinha()


func criar_proxima_vinha() -> void:
	if current_vine >= vine_scenes.size():
		spawn_timer.stop()
		return

	var vinha = vine_scenes[current_vine].instantiate()

	get_tree().current_scene.add_child(vinha)

	var offset = vine_offsets[current_vine]
	offset.x *= direction

	vinha.global_position = spawn_position + offset

	current_vine += 1

	if current_vine < vine_scenes.size():
		spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	criar_proxima_vinha()


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
