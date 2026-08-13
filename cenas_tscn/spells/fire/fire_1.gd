extends Node2D

var duration = 10.0
var cooldown = 15.0
var mana_cost = 10.0

var cooldown_timer: Timer


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)


func use(player) -> void:
	if !cooldown_timer.is_stopped():
		return

	if player.Mana < mana_cost:
		return

	player.Mana -= mana_cost
	player.imbue_element(0, duration)

	cooldown_timer.start()


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
