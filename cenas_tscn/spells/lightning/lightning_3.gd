extends Node2D

var player = null
var active = false
var shot_fired = false

var duration = 2.0
var cooldown = 25.0
var mana_cost = 30

var cooldown_remaining = 0.0

var bolt_scene = preload("res://cenas_tscn/spells/lightning/lightning_bolt.tscn")

@onready var duration_timer: Timer = $DurationTimer
@onready var delay_timer: Timer = $DelayTimer


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
	shot_fired = false

	player.spell_in_use = true
	player.active_spell = self

	duration_timer.start(duration)
	delay_timer.start(1.0)


func disparar_raio() -> void:
	if !active:
		return

	if shot_fired:
		return

	if player == null:
		return

	shot_fired = true

	var bolt = bolt_scene.instantiate()

	get_tree().current_scene.add_child(bolt)

	var direction = Vector2(player.last_direction, 0)

	bolt.global_position = player.global_position + Vector2(
		45 * player.last_direction,
		0
	)

	bolt.setup(player, direction)


func finalizar_magia() -> void:
	if !active:
		return

	active = false
	shot_fired = false

	duration_timer.stop()
	delay_timer.stop()

	cooldown_remaining = cooldown

	if player != null:
		player.finalizar_magia()

	player = null


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_remaining / cooldown


func _on_delay_timer_timeout() -> void:
	disparar_raio()


func _on_duration_timer_timeout() -> void:
	finalizar_magia()
