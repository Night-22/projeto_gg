extends Enemy

@export var velocidade_perseguicao := 120.0
@export var distancia_explosao := 35.0
@export var dano_explosao := 20


var player: Node2D = null
var explodindo := false


func _physics_process(delta):
	if dead or explodindo:
		return

	if player != null:
		var distancia = global_position.distance_to(player.global_position)

		dir = sign(player.global_position.x - global_position.x)

		if dir == 0:
			dir = 1

		Speed = velocidade_perseguicao

		if distancia <= distancia_explosao:
			explodir()

	super._physics_process(delta)


func explodir():
	if explodindo:
		return

	explodindo = true
	Speed = 0
	velocity = Vector2.ZERO

	if player != null and player.has_method("receber_dano"):
		player.receber_dano(dano_explosao, global_position.x)

	queue_free()


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
