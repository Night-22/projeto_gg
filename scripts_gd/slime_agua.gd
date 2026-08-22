extends Enemy

@export var walk_speed: float = 40.0

@export var mini_jump_force: float = -120.0
@export var mini_jump_speed: float = 40.0

@export var leap_speed: float = 140.0
@export var leap_force: float = -280.0

@export var limite_altura: float = 30.0

@onready var area: Area2D = $percepcao
@onready var timer: Timer = $Timer
@onready var anim: AnimatedSprite2D = $anim
@onready var ray_floor: RayCast2D = $ray_floor

var player: Node2D = null

var can_jump := true
var jumping := false
var attacking := false

var ray_position_x := 0.0


func _ready() -> void:
	Speed = walk_speed
	ray_position_x = abs(ray_floor.position.x)
	atualizar_direcao()


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var player_dentro_da_altura := false

	if player != null and is_instance_valid(player):
		var diferenca_y = abs(player.global_position.y - global_position.y)
		player_dentro_da_altura = diferenca_y <= limite_altura

		if player_dentro_da_altura and not jumping:
			var nova_direcao = sign(
				player.global_position.x - global_position.x
			)

			if nova_direcao != 0:
				dir = nova_direcao
				atualizar_direcao()

	if player != null and is_instance_valid(player) and player_dentro_da_altura:
		if can_jump and is_on_floor():
			iniciar_pulo_perseguicao()
	else:
		if can_jump and is_on_floor():
			iniciar_mini_pulo()

	if knockback.length() > 10:
		velocity.x = knockback.x
		knockback.x = move_toward(
			knockback.x,
			0,
			500 * delta
		)
	else:
		velocity.x = dir * Speed

	move_and_slide()

	ray_floor.force_raycast_update()

	if is_on_floor() and not ray_floor.is_colliding() and not attacking:
		dir *= -1
		atualizar_direcao()

	if is_on_wall() and not attacking:
		dir *= -1
		atualizar_direcao()

	if attacking:
		anim.play("attack")
	elif velocity.x != 0:
		anim.play("walk")


func iniciar_mini_pulo() -> void:
	jumping = true
	attacking = false
	can_jump = false

	Speed = mini_jump_speed
	velocity.y = mini_jump_force

	timer.start()


func iniciar_pulo_perseguicao() -> void:
	jumping = true
	attacking = true
	can_jump = false

	var nova_direcao = sign(
		player.global_position.x - global_position.x
	)

	if nova_direcao != 0:
		dir = nova_direcao
		atualizar_direcao()

	Speed = leap_speed
	velocity.y = leap_force

	timer.start()


func atualizar_direcao() -> void:
	ray_floor.position.x = ray_position_x * dir
	anim.flip_h = dir > 0


func _on_timer_timeout() -> void:
	can_jump = true
	jumping = false
	attacking = false
	Speed = walk_speed


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		attacking = false
