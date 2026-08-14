extends Node2D

var player = null
var active = false

var duration = 1.0
var cooldown = 20.0
var mana_cost = 25

var cooldown_remaining = 0.0

var ball_scene = preload("res://cenas_tscn/spells/lightning/lightning_4_ball.tscn")

@onready var duration_timer: Timer = $DurationTimer


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

	duration_timer.start(duration)

	disparar_bolas()


func disparar_bolas() -> void:
	if player == null:
		return

	var direcao = player.last_direction

	var angulos = [
		-30.0,
		-15.0,
		0.0,
		15.0,
		30.0
	]

	for angulo in angulos:
		var bola = ball_scene.instantiate()

		get_tree().current_scene.add_child(bola)

		bola.global_position = player.global_position

		var direction = Vector2(direcao, 0).rotated(
			deg_to_rad(angulo)
		)

		bola.setup(player, direction)


func finalizar_magia() -> void:
	active = false

	cooldown_remaining = cooldown

	player = null


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_remaining / cooldown


func _on_duration_timer_timeout() -> void:
	finalizar_magia()
