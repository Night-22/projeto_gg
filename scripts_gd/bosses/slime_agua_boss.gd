extends Enemy
class_name SlimeAguaBoss

@export var velocidade_perseguicao := 26.0
@export var tempo_vida_maxima := 12.0

var jogador: Node2D = null


func _ready() -> void:
	super._ready()

	Speed = velocidade_perseguicao
	max_elementos = 2

	jogador = get_tree().get_first_node_in_group("Player")

	get_tree().create_timer(tempo_vida_maxima).timeout.connect(_expirar)


func _physics_process(delta: float) -> void:
	if dead:
		return

	if jogador and is_instance_valid(jogador):
		var nova_direcao := signf(jogador.global_position.x - global_position.x)

		if nova_direcao != 0.0:
			dir = nova_direcao

	super._physics_process(delta)


func _expirar() -> void:
	if dead:
		return

	dead = true
	queue_free()
