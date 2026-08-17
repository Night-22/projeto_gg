extends Node2D

var duration = 5.0
var cooldown = 15.0
var mana_cost = 20

var cooldown_timer: Timer

var thorn_scene = preload("res://cenas_tscn/spells/plant/plant_2_thorn.tscn")


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)


func use(owner_player) -> void:
	if !cooldown_timer.is_stopped():
		return

	if owner_player.Mana < mana_cost:
		return

	owner_player.Mana -= mana_cost

	var thorn = thorn_scene.instantiate()

	get_tree().current_scene.add_child(thorn)

	thorn.global_position = owner_player.global_position

	if thorn.has_method("iniciar"):
		thorn.iniciar(owner_player)

	cooldown_timer.start()


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
