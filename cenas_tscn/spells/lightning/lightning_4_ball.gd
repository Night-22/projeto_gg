extends Area2D

var player = null
var direction := Vector2.ZERO
var speed := 500.0
var damage := 5


func setup(owner_player, shot_direction: Vector2) -> void:
	player = owner_player
	direction = shot_direction.normalized()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		return

	if body.is_in_group("ProjetilJogador") or body.is_in_group("ProjetilInimigo"):
		return

	if body.is_in_group("Inimigo"):
		if body.has_method("_aplicar_elemento"):
			damage = body._aplicar_elemento(
				2,
				damage,
				global_position.x
			)

		body._dano(damage, global_position.x)

		queue_free()
		return

	# Colidiu com algo que não toma dano (parede, chão, etc) -> destrói o projétil
	queue_free()
