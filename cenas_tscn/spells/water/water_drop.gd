extends Area2D

var speed = 700.0
var damage = 3
var direction = Vector2.RIGHT
var player = null
var max_distance = 1300.0
var start_position = Vector2.ZERO


func setup(owner_player, shoot_direction: Vector2) -> void:
	player = owner_player
	direction = shoot_direction.normalized()
	start_position = global_position


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	if global_position.distance_to(start_position) >= max_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		return

	if body.is_in_group("ProjetilJogador") or body.is_in_group("ProjetilInimigo"):
		return

	if body.is_in_group("Inimigo"):
		var final_damage = damage

		if body.has_method("_aplicar_elemento"):
			final_damage = body._aplicar_elemento(
				1,
				final_damage,
				global_position.x
			)

		if body.has_method("_dano"):
			body._dano(
				final_damage,
				global_position.x
			)

		queue_free()
		return

	# Colidiu com algo que não toma dano (parede, chão, etc) -> destrói o projétil
	queue_free()
