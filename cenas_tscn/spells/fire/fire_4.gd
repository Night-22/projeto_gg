extends Node2D

var duration = 2.0
var cooldown = 30.0
var mana_cost = 35

var cooldown_timer: Timer

var player = null
var fire_position := Vector2.ZERO

var fire_projectile_scene = preload("res://cenas_tscn/spells/fire/fire_4_projectile.tscn")

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

	fire_position = player.global_position

	delay_timer.start(0.05)


func criar_projeteis() -> void:
	if player == null:
		return

	var direcao = player.last_direction

	var velocidades = [
		Vector2(400 * direcao, -400),
		Vector2(425 * direcao, -450),
		Vector2(450 * direcao, -425)
	]

	for velocidade in velocidades:
		var projectile = fire_projectile_scene.instantiate()

		get_tree().current_scene.add_child(projectile)

		projectile.global_position = fire_position

		if projectile.has_method("iniciar"):
			projectile.iniciar(
				player,
				velocidade
			)

	cooldown_timer.start()

	player = null


func _on_delay_timer_timeout() -> void:
	criar_projeteis()


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
