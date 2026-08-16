extends Area2D

var player = null
var target = null

var duration = 10.0
var duration_timer = 0.0

var speed = 250.0
var detection_range = 450.0
var damage = 6


func iniciar(owner_player, _direction: float, spell_duration: float) -> void:
	player = owner_player
	duration = spell_duration
	duration_timer = duration


func _physics_process(delta: float) -> void:
	duration_timer -= delta

	if duration_timer <= 0:
		queue_free()
		return

	if player == null:
		queue_free()
		return

	if target == null or !is_instance_valid(target):
		procurar_alvo()

	if target != null and is_instance_valid(target):
		perseguir_alvo(delta)
	else:
		mover_sem_alvo(delta)


func procurar_alvo() -> void:
	var inimigos = get_tree().get_nodes_in_group("Inimigo")

	var menor_distancia = detection_range
	var melhor_alvo = null

	for inimigo in inimigos:
		if !is_instance_valid(inimigo):
			continue

		var distancia = global_position.distance_to(inimigo.global_position)

		if distancia <= menor_distancia:
			menor_distancia = distancia
			melhor_alvo = inimigo

	target = melhor_alvo


func perseguir_alvo(delta: float) -> void:
	var direcao = global_position.direction_to(target.global_position)

	global_position += direcao * speed * delta


func mover_sem_alvo(delta: float) -> void:
	global_position.x += player.last_direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Inimigo"):
		return

	var dano = damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			3,
			dano,
			global_position.x
		)

	body._dano(dano, global_position.x)

	queue_free()
