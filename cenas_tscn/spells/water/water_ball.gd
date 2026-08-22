extends Area2D

var player = null
var direction := Vector2.ZERO
var speed := 700.0
var damage := 50


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
		var dano = damage

		if body.has_method("_aplicar_elemento"):
			dano = body._aplicar_elemento(
				1,
				dano,
				global_position.x
			)

		body._dano(dano, global_position.x)

		return

	# Colidiu com algo que não toma dano (parede, chão, etc) -> destrói o projétil
	queue_free()
