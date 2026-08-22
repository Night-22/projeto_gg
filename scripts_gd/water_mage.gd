extends Enemy

@onready var water = preload("res://cenas_tscn/ataque_agua.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var ray_cast: RayCast2D = $rayCast
@onready var anim: AnimatedSprite2D = $anim
@onready var percepcao: Area2D = $percepcao

var player: Node2D = null

var atacando := false
var tiro_disparado := false
var player_detectado := false
var player_visivel := false

@export var alcance_maximo := 180.0
@export var distancia_do_cajado := 20.0

var dir_patrol := -1


func _ready() -> void:
	dir_patrol = dir
	anim.play("walk")


func _physics_process(delta: float) -> void:
	if dead:
		return

	if player_detectado and player != null and is_instance_valid(player):
		atualizar_raycast()
		verificar_player()

		if player_visivel:
			dir_patrol = dir

			olhar_para_player()
			tentar_atacar()

			velocity.x = 0

			if knockback.length() <= 10:
				move_and_slide()

			return

	dir = dir_patrol

	super._physics_process(delta)

	dir_patrol = dir

	if not atacando:
		anim.play("walk")


func atualizar_raycast() -> void:
	ray_cast.target_position = ray_cast.to_local(player.global_position)
	ray_cast.force_raycast_update()


func verificar_player() -> void:
	player_visivel = false

	if player == null or !is_instance_valid(player):
		return

	var distancia := global_position.distance_to(player.global_position)

	if distancia > alcance_maximo:
		return

	if !ray_cast.is_colliding():
		return

	var collider = ray_cast.get_collider()

	if collider != null and collider.is_in_group("Player"):
		player_visivel = true


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


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_detectado = true


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player_detectado = false
		player_visivel = false
		player = null
		atacando = false
