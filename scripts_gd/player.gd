extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	FALL,
	DASH,
	DEAD
}

var current_state = State.IDLE

var Life = 3

@export var max_speed = 300.0
@export var acceleration = 2.5
@export var friction = 6.7

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hit_box: CollisionShape2D = $attackHitBox/collision
@onready var attack_sprite: Sprite2D = $attackHitBox/Sprite2D

@onready var attack_timer: Timer = $attackTimer

var coyote_time_activated = false
@onready var coyote_timer: Timer = $coyoteTimer

var speed: float = 300.0
var jump_velocity = -500.0
var pogo_velocity = -400.0

var last_direction = 1
var can_attack = true
var looking_up = false
var looking_down = false


var jump_count = 0
var max_jumps = 2


var dash_speed = 400.0
var dash_time = 0.25
var dash_timer = 0.0


var air_dash_available = true


func _physics_process(delta: float) -> void:

	if Life <= 0:
		current_state = State.DEAD

	if is_on_floor():
		jump_count = 0
		air_dash_available = true

	looking_up = Input.is_action_pressed("cima")
	looking_down = Input.is_action_pressed("baixo")

	match current_state:

		State.IDLE:
			state_idle(delta)
			anim.play("idle")

		State.WALK:
			state_walk(delta)
			anim.play("walk")

		State.JUMP:
			state_jump(delta)
			anim.play("jump")

		State.ATTACK:
			state_attack(delta)

		State.FALL:
			state_fall(delta)
			anim.play("fall")

		State.DASH:
			state_dash(delta)

		State.DEAD:
			state_dead()

	move_and_slide()


func state_idle(delta):

	anim.flip_h = last_direction < 0

	velocity.x = lerp(
		velocity.x,
		0.0,
		delta * friction
	)

	if Input.is_action_just_pressed("pulo"):
		jump()
		return

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	if direction != 0:
		current_state = State.WALK
		return

	if !is_on_floor():
		start_coyote()
		current_state = State.FALL


func state_walk(delta):

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * speed,
		delta * acceleration
	)

	if Input.is_action_just_pressed("pulo"):
		jump()
		return

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK

	if direction == 0:
		current_state = State.IDLE
		return

	if !is_on_floor():
		start_coyote()
		current_state = State.FALL


func state_jump(delta):

	velocity += get_gravity() * delta

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * speed,
		delta * acceleration
	)


	if Input.is_action_just_pressed("pulo") and jump_count < max_jumps:
		jump()
		return

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return

	var jump_force = Input.get_action_strength("pulo")

	if velocity.y < 0:
		if Input.is_action_just_released("pulo"):
			velocity.y *= jump_force

	if velocity.y >= 0:
		current_state = State.FALL

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK


func state_attack(delta):

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	if Input.is_action_pressed("ataque") and can_attack:
		can_attack = false
		attack_hit_box.disabled = false
		attack_sprite.visible = true
		attack_timer.start()

	if last_direction < 0:
		attack_to_direction("left")
	else:
		attack_to_direction("right")

	if looking_up:
		attack_to_direction("up")

	if looking_down:
		attack_to_direction("down")

	if is_on_floor():
		if direction != 0:
			current_state = State.WALK
		else:
			current_state = State.IDLE

	if !is_on_floor():
		if velocity.y > 0:
			current_state = State.FALL
		else:
			current_state = State.JUMP


func state_fall(delta):

	velocity += get_gravity() * delta

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * speed,
		delta * acceleration
	)

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return

	if Input.is_action_just_pressed("pulo"):
		if coyote_time_activated:
			jump()
			return
		elif jump_count < max_jumps:
			jump()
			return

	if is_on_floor():
		coyote_time_activated = false
		coyote_timer.stop()

		if direction == 0:
			current_state = State.IDLE
		else:
			current_state = State.WALK


func state_dash(delta):

	dash_timer -= delta

	velocity.y = 0
	velocity.x = dash_speed * last_direction

	anim.flip_h = last_direction < 0

	if dash_timer <= 0:
		if is_on_floor():

			var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

			if direction == 0:
				current_state = State.IDLE
			else:
				current_state = State.WALK

		else:
			current_state = State.FALL


func state_dead():
	die()


func jump():

	velocity.y = jump_velocity
	jump_count += 1

	coyote_time_activated = false
	coyote_timer.stop()

	current_state = State.JUMP


func start_dash():

	if !is_on_floor():
		if !air_dash_available:
			return

		air_dash_available = false

	dash_timer = dash_time
	current_state = State.DASH

	if last_direction == 0:
		last_direction = 1

	velocity.y = 0


func start_coyote():

	if coyote_timer.is_stopped():
		coyote_time_activated = true
		coyote_timer.start()


func attack_to_direction(dir):

	match dir:

		"right":
			anim.flip_h = false
			attack_sprite.flip_h = false

			attack_hit_box.position = Vector2(23, 0)
			attack_hit_box.rotation = 0

			attack_sprite.position = Vector2(23, 0)
			attack_sprite.rotation = 0

		"left":
			anim.flip_h = true
			attack_sprite.flip_h = true

			attack_hit_box.position = Vector2(-23, 0)
			attack_hit_box.rotation = 0

			attack_sprite.position = Vector2(-23, 0)
			attack_sprite.rotation = 0

		"up":
			attack_sprite.flip_h = false

			attack_hit_box.position = Vector2(0, -23)
			attack_hit_box.rotation = -1.57079633

			attack_sprite.position = Vector2(0, -23)
			attack_sprite.rotation = -1.57079633

		"down":
			attack_sprite.flip_h = false

			attack_hit_box.position = Vector2(0, 23)
			attack_hit_box.rotation = 1.57079633

			attack_sprite.position = Vector2(0, 23)
			attack_sprite.rotation = 1.57079633


func die():
	queue_free()


func _on_hurt_box_body_entered(body: Node2D) -> void:

	if body.is_in_group("Inimigo"):
		Life -= 1
		print(Life)


func _on_attack_hit_box_body_entered(body: Node2D) -> void:

	if body is Enemy:
		body._dano(2, global_position.x)

		if looking_down and !is_on_floor():

			velocity.y = pogo_velocity

			jump_count = min(jump_count + 1, max_jumps)

			current_state = State.JUMP


func _on_coyote_timer_timeout() -> void:
	coyote_time_activated = false

	if !is_on_floor() and jump_count == 0:
		jump_count = 1


func _on_attack_timer_timeout() -> void:

	can_attack = true
	attack_sprite.visible = false
	attack_hit_box.disabled = true
