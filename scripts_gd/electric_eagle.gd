extends Flying

@onready var water = preload("res://cenas_tscn/ataque_raio.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var percepcao: Area2D = $percepcao
@onready var anim: AnimatedSprite2D = $anim

var player: Node2D = null
var atacando := false

@export var distancia_do_ataque := 10.0
@export var velocidade_patrulha := 40.0

@export var angulo_dos_tiros := 40.0


func _ready() -> void:
	anim.play("voo")


func _physics_process(delta: float) -> void:
	if dead:
		return

	if player != null and player_esta_na_percepcao():
		# Player à vista: para no lugar, encara e atira.
		velocity = Vector2.ZERO

		olhar_para_player()

		if !atacando and cooldown.is_stopped():
			disparar_rajada()
	else:
		# Patrulha normal: anda até bater em parede ou em
		# outro inimigo, aí vira, igual aos demais inimigos.
		velocity.x = dir * velocidade_patrulha
		velocity.y = 0.0

		if velocity.x > 0:
			anim.flip_h = true
		elif velocity.x < 0:
			anim.flip_h = false

	move_and_slide()

	if is_on_wall():
		dir *= -1

	if !anim.is_playing() or anim.animation != "voo":
		anim.play("voo")


func olhar_para_player() -> void:
	if player.global_position.x > global_position.x:
		anim.flip_h = true
	else:
		anim.flip_h = false


func _on_percepcao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	player = body

	if !atacando and cooldown.is_stopped():
		disparar_rajada()


func disparar_rajada() -> void:
	if !player_esta_na_percepcao():
		return

	atacando = true

	var direcao = player.global_position - global_position
	var angulo = direcao.angle()
	var abertura = deg_to_rad(angulo_dos_tiros)

	disparar_agua(Vector2.from_angle(angulo - abertura))
	disparar_agua(Vector2.from_angle(angulo))
	disparar_agua(Vector2.from_angle(angulo + abertura))

	atacando = false
	cooldown.start()


func disparar_agua(direcao: Vector2) -> void:
	var ataque = water.instantiate()

	ataque.global_position = global_position + direcao * distancia_do_ataque
	ataque.direction = direcao

	get_parent().add_child(ataque)


func player_esta_na_percepcao() -> bool:
	for body in percepcao.get_overlapping_bodies():
		if body.is_in_group("Player"):
			player = body
			return true

	player = null
	return false


func _on_cooldown_timeout() -> void:
	if player_esta_na_percepcao() and !atacando:
		disparar_rajada()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
