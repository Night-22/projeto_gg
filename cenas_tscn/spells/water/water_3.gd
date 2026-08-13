extends Node2D

var player = null
var active = false

var duration = 3.0
var cooldown = 20.0
var mana_cost = 20

var cooldown_remaining = 0.0

var drop_scene = preload("res://cenas_tscn/spells/water/water_drop.tscn")

@onready var shoot_timer: Timer = $ShootTimer
@onready var duration_timer: Timer = $DurationTimer


func use(owner_player) -> void:
	if active:
		return

	if cooldown_remaining > 0:
		return

	if owner_player.Mana < mana_cost:
		return

	player = owner_player

	owner_player.Mana -= mana_cost

	active = true
	cooldown_remaining = cooldown

	duration_timer.start(duration)
	shoot_timer.start()

	disparar_gota()


func disparar_gota() -> void:
	if !active:
		return

	if player == null:
		return

	var drop = drop_scene.instantiate()

	get_tree().current_scene.add_child(drop)

	var direction = Vector2(player.last_direction, 0)

	drop.global_position = player.global_position + Vector2(
		35 * player.last_direction,
		0
	)

	drop.setup(player, direction)


func finalizar_magia() -> void:
	active = false

	shoot_timer.stop()

	if player != null:
		player.finalizar_magia()

	player = null


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_remaining / cooldown


func _process(delta: float) -> void:
	if cooldown_remaining > 0:
		cooldown_remaining = max(
			cooldown_remaining - delta,
			0.0
		)


func _on_shoot_timer_timeout() -> void:
	disparar_gota()


func _on_duration_timer_timeout() -> void:
	finalizar_magia()
