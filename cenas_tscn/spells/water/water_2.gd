extends Node2D

var duration = 3.0
var cooldown = 25.0
var mana_cost = 25
var damage = 2
var element = 1

var cooldown_timer: Timer
var duration_timer: Timer
var player = null
var active = false

@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)

	duration_timer = Timer.new()
	duration_timer.one_shot = true
	duration_timer.wait_time = duration
	add_child(duration_timer)

	area.monitoring = false
	sprite.visible = false

	duration_timer.timeout.connect(_on_duration_timeout)
	area.body_entered.connect(_on_area_body_entered)


func use(caster) -> void:
	if active:
		return

	if !cooldown_timer.is_stopped():
		return

	if caster.Mana < mana_cost:
		return

	player = caster

	player.Mana -= mana_cost

	active = true
	area.monitoring = true
	sprite.visible = true

	cooldown_timer.start()
	duration_timer.start()


func _on_duration_timeout() -> void:
	active = false
	area.monitoring = false
	sprite.visible = false


func _on_area_body_entered(body: Node2D) -> void:
	if !active:
		return

	if body.is_in_group("Inimigo"):
		var final_damage = damage

		if body.has_method("_aplicar_elemento"):
			final_damage = body._aplicar_elemento(
				element,
				damage,
				player.global_position.x
			)

		if body.has_method("_dano"):
			body._dano(
				final_damage,
				player.global_position.x
			)


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
