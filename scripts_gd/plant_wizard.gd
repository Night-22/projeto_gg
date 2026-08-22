extends Enemy

@onready var water = preload("res://cenas_tscn/ataque_planta.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var ray_cast: RayCast2D = $rayCast
@onready var anim: AnimatedSprite2D = $anim

var player: Node2D
var atacando := false
var tiro_disparado := false
var player_detectado := false

@export var alcance_maximo := 180.0
@export var distancia_do_cajado := 20.0

var dir_patrol := -1


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

	# Guarda a direção inicial da patrulha
	dir_patrol = dir

	anim.play("walk")


func _physics_process(delta: float) -> void:
	if dead:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("Player")

		if player == null:
			super._physics_process(delta)
			return

	atualizar_raycast()
	verificar_player()

	if player_detectado:
		# Guarda a direção da patrulha
		# antes de zerar
		if dir != 0:
			dir_patrol = dir

		# Faz o Enemy parar horizontalmente
		dir = 0

		olhar_para_player()
		tentar_atacar()

	else:
		# Recupera a direção da patrulha
		dir = dir_patrol

	# Enemy continua cuidando da física,
	# knockback, gravidade, colisões etc.
	super._physics_process(delta)

	# Se estiver detectando o Player e não estiver
	# sofrendo knockback, garante que fique parado.
	if player_detectado and knockback.length() <= 10:
		velocity.x = 0


func atualizar_raycast() -> void:
	ray_cast.target_position = ray_cast.to_local(player.global_position)
	ray_cast.force_raycast_update()


func verificar_player() -> void:
	player_detectado = false

	var distancia := global_position.distance_to(player.global_position)

	if distancia > alcance_maximo:
		return

	if !ray_cast.is_colliding():
		return

	var collider = ray_cast.get_collider()

	if collider == null:
		return

	if collider.is_in_group("Player"):
		player_detectado = true


func olhar_para_player() -> void:
	if player.global_position.x > global_position.x:
		anim.flip_h = true
	else:
		anim.flip_h = false


func tentar_atacar() -> void:
	if atacando:
		return

	if !cooldown.is_stopped():
		return

	atacando = true
	tiro_disparado = false

	anim.play("attack")


func _on_anim_frame_changed() -> void:
	if anim.animation != "attack":
		return

	if anim.frame == 2 and !tiro_disparado:
		tiro_disparado = true
		disparar_agua()


func disparar_agua() -> void:
	if player == null:
		return

	var direcao := (
		player.global_position - global_position
	).normalized()

	var ataque = water.instantiate()

	ataque.global_position = (
		global_position + direcao * distancia_do_cajado
	)

	ataque.direction = direcao

	get_parent().add_child(ataque)


func _on_anim_animation_finished() -> void:
	if anim.animation != "attack":
		return

	anim.play("walk")

	cooldown.start()

	await cooldown.timeout

	atacando = false
	tiro_disparado = false
