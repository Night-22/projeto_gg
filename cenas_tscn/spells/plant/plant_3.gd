extends Node2D

var duration = 0.5
var plants_duration = 4
var cooldown = 10.0
var mana_cost = 15

var projectile_scene = preload("res://cenas_tscn/spells/plant/plant_3_projectile.tscn")

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

	for i in range(3):
		criar_planta(player, i)

	cooldown_timer.start()


func criar_planta(player, index: int) -> void:
	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	var direcao = player.last_direction

	var offsets = [
		Vector2(0, -20),
		Vector2(0, 0),
		Vector2(0, 20)
	]

	projectile.global_position = player.global_position + Vector2(
		45 * direcao,
		0
	) + offsets[index]

	projectile.iniciar(player, direcao, plants_duration)


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown


func _on_cooldown_timer_timeout() -> void:
	pass 
