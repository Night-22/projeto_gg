extends Node2D

var duration = 0.4
var cooldown = 15.0
var mana_cost = 25
var damage = 3

var player = null
var active = false

var cooldown_timer: Timer
var duration_timer: Timer

@onready var hit_box: Area2D = $HitBox
@onready var collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown
	add_child(cooldown_timer)

	duration_timer = Timer.new()
	duration_timer.one_shot = true
	duration_timer.wait_time = duration
	duration_timer.timeout.connect(_on_duration_timeout)
	add_child(duration_timer)

	hit_box.body_entered.connect(_on_hit_box_body_entered)

	collision.disabled = true
	sprite.visible = false


func use(owner_player) -> void:
	if active:
		return

	if !cooldown_timer.is_stopped():
		return

	if owner_player.Mana < mana_cost:
		return

	player = owner_player

	player.Mana -= mana_cost

	active = true

	collision.disabled = false
	sprite.visible = true
	sprite.play("default")

	duration_timer.start()
	cooldown_timer.start()

	atualizar_direcao()


func _process(_delta: float) -> void:
	if !active:
		return

	if player == null:
		return

	atualizar_direcao()


func atualizar_direcao() -> void:
	if player.last_direction > 0:
		hit_box.position = Vector2(30, 0)
		hit_box.scale.x = 1

		sprite.position = Vector2(30, 0)
		sprite.flip_h = false
	else:
		hit_box.position = Vector2(-30, 0)
		hit_box.scale.x = -1

		sprite.position = Vector2(-30, 0)
		sprite.flip_h = true


func _on_hit_box_body_entered(body: Node2D) -> void:
	if !active:
		return

	if !body.is_in_group("Inimigo"):
		return

	var dano = damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			0,
			dano,
			player.global_position.x
		)

	body._dano(dano, player.global_position.x)


func _on_duration_timeout() -> void:
	finalizar_magia()


func finalizar_magia() -> void:
	active = false
	collision.disabled = true
	sprite.visible = false
	player = null


func is_on_cooldown() -> bool:
	return !cooldown_timer.is_stopped()


func get_cooldown_remaining() -> float:
	return cooldown_timer.time_left


func get_cooldown_percent() -> float:
	if cooldown <= 0:
		return 0.0

	return cooldown_timer.time_left / cooldown
