extends Node2D

var player = null

var velocity := Vector2.ZERO
var gravity := 1000.0

var damage = 10
var explosion_damage = 12

var exploded = false


func iniciar(owner_player, initial_velocity: Vector2) -> void:
	player = owner_player
	velocity = initial_velocity

	if player != null:
		$RayCast2D.add_exception(player)


func _physics_process(delta: float) -> void:
	if exploded:
		return

	velocity.y += gravity * delta

	position += velocity * delta

	if $RayCast2D.is_colliding():
		explodir()


func explodir() -> void:
	if exploded:
		return

	exploded = true

	velocity = Vector2.ZERO

	$Area2D.monitoring = false
	$ExplosionArea.monitoring = true

	$ExplosionTimer.start()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if exploded:
		return

	if !body.is_in_group("Inimigo"):
		return

	var dano = damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			0,
			dano,
			global_position.x
		)

	body._dano(dano, global_position.x)


func _on_explosion_area_body_entered(body: Node2D) -> void:
	if !exploded:
		return

	if !body.is_in_group("Inimigo"):
		return

	var dano = explosion_damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			0,
			dano,
			global_position.x
		)

	body._dano(dano, global_position.x)


func _on_explosion_timer_timeout() -> void:
	queue_free()
