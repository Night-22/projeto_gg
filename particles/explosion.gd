extends Node2D

var alvo: Node2D = null


func _ready() -> void:
	$CPUParticles2D.emitting = true

	get_tree().create_timer($CPUParticles2D.lifetime + 0.1).timeout.connect(queue_free)


func _process(_delta: float) -> void:
	if alvo == null:
		set_process(false)
		return

	if not is_instance_valid(alvo):
		alvo = null
		set_process(false)
		return

	global_position = alvo.global_position



func configurar(alvo_node: Node2D, cor: Color, direcao: Vector2) -> void:
	seguir(alvo_node)
	definir_cor(cor)
	definir_direcao(direcao)


func seguir(alvo_node: Node2D) -> void:
	alvo = alvo_node

	if is_instance_valid(alvo):
		global_position = alvo.global_position


func definir_cor(cor: Color) -> void:
	$CPUParticles2D.color = cor


func definir_direcao(direcao: Vector2) -> void:
	if direcao == Vector2.ZERO:
		return

	$CPUParticles2D.direction = direcao.normalized()
