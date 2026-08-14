extends Node2D

var player = null
var active = false

var duration = 1.0
var cooldown = 15.0
var mana_cost = 15

var ball_scene = preload("res://cenas_tscn/spells/water/water_ball.tscn")

var cooldown_remaining = 0.0


func _process(delta: float) -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= delta

		if cooldown_remaining < 0:
			cooldown_remaining = 0


func use(owner_player) -> void:
	if active:
		return

	if cooldown_remaining > 0:
		return

	if owner_player.Mana < mana_cost:
		return

	player = owner_player

	player.Mana -= mana_cost

	active = true

	disparar_bola()

	cooldown_remaining = cooldown

	active = false
	player = null


func disparar_bola() -> void:
	if player == null:
		return

	var ball = ball_scene.instantiate()

	get_tree().current_scene.add_child(ball)

	var direction = Vector2(player.last_direction, 0)

	ball.global_position = player.global_position + Vector2(
		45 * player.last_direction,
		0
	)

	ball.setup(player, direction)


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_remaining / cooldown
