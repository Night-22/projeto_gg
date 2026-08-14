extends Enemy

@export var normal_speed := 80
@export var chase_speed := 200
@export var dano_contato := 1

@onready var raycast: RayCast2D = $rayCast
@onready var tempo_virar: Timer = $tempo_virar

var player: Node2D = null
var usando_investida := false


func _physics_process(delta):
	if player != null and !is_instance_valid(player):
		player = null
		usando_investida = false
		Speed = normal_speed
		tempo_virar.stop()

	super._physics_process(delta)


func virar():
	if player == null or !is_instance_valid(player):
		return

	if not usando_investida:
		return

	if player.global_position.x > global_position.x:
		dir = 1
		raycast.target_position.x = abs(raycast.target_position.x)
	else:
		dir = -1
		raycast.target_position.x = -abs(raycast.target_position.x)


func iniciar_investida():
	if player == null or !is_instance_valid(player):
		return

	if usando_investida:
		return

	usando_investida = true
	Speed = chase_speed
	tempo_virar.start()


func finalizar_investida():
	usando_investida = false
	Speed = normal_speed
	tempo_virar.stop()


func _on_tempo_virar_timeout() -> void:
	if usando_investida and player != null and is_instance_valid(player):
		virar()

	finalizar_investida()


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		iniciar_investida()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		finalizar_investida()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_dano(dano_contato, body.global_position.x)
