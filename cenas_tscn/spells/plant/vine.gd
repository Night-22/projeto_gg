extends Node2D

@export var damage := 8
@export var lifetime := 0.8

var already_damaged = false
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	$Area2D.monitoring = true

	var timer = Timer.new()
	sprite_2d.play("default")
	timer.one_shot = true
	timer.wait_time = lifetime
	timer.timeout.connect(_on_lifetime_timeout)
	add_child(timer)
	timer.start()
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if already_damaged:
		return

	if !body.is_in_group("Inimigo"):
		return

	already_damaged = true

	var dano = damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			3,
			dano,
			global_position.x
		)

	body._dano(dano, global_position.x)


func _on_lifetime_timeout() -> void:
	queue_free()
