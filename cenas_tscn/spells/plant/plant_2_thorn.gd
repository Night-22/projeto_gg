extends Node2D

var player = null

var speed = 600.0
var max_distance = 1000.0

var direction := Vector2.ZERO
var start_position := Vector2.ZERO

var returning = false
var elapsed_time = 0.0
var duration = 5.0

var damage = 15

var enemies_hit = []


func iniciar(owner_player) -> void:
	player = owner_player

	start_position = player.global_position

	direction = Vector2(player.last_direction, 0)

	if direction.x < 0:
		$Sprite2D.flip_h = true


func _physics_process(delta: float) -> void:
	if player == null:
		queue_free()
		return

	elapsed_time += delta

	if elapsed_time >= duration:
		queue_free()
		return

	if !returning:
		position += direction * speed * delta

		if global_position.distance_to(start_position) >= max_distance:
			returning = true
			enemies_hit.clear()
	else:
		var to_player = player.global_position - global_position

		if to_player.length() <= 20.0:
			queue_free()
			return

		position += to_player.normalized() * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		return

	if body.is_in_group("ProjetilJogador") or body.is_in_group("ProjetilInimigo"):
		return

	if body.is_in_group("Inimigo"):
		if body in enemies_hit:
			return

		enemies_hit.append(body)

		var dano = damage

		if body.has_method("_aplicar_elemento"):
			dano = body._aplicar_elemento(
				3,
				dano,
				global_position.x
			)

		body._dano(dano, global_position.x)
		return

	# Colidiu com algo que não toma dano (parede, chão, etc) -> destrói o projétil
	queue_free()
