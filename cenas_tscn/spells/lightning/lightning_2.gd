extends Node2D

var player = null
var active = false

var duration = 2.5
var cooldown = 20.0
var mana_cost = 25

var cooldown_remaining = 0.0
var locked_position := Vector2.ZERO

@onready var duration_timer: Timer = $DurationTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var lightning_area: Area2D = $LightningArea


func _ready() -> void:
	sprite.visible = false
	lightning_area.monitoring = false


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

	locked_position = player.global_position

	player.spell_in_use = true
	player.active_spell = self

	player.velocity = Vector2.ZERO

	sprite.visible = true
	lightning_area.monitoring = true

	duration_timer.start(duration)


func _physics_process(_delta: float) -> void:
	if !active:
		return

	if player == null:
		return

	player.global_position = locked_position
	player.velocity = Vector2.ZERO


func finalizar_magia() -> void:
	if !active:
		return

	active = false

	duration_timer.stop()

	cooldown_remaining = cooldown

	sprite.visible = false
	lightning_area.monitoring = false

	if player != null:
		player.velocity = Vector2.ZERO
		player.finalizar_magia()

	player = null


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_remaining / cooldown


func _on_duration_timer_timeout() -> void:
	finalizar_magia()
