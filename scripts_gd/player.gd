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

enum Spell {
	WATER_1,
	WATER_2,
	WATER_3,
	WATER_4,
	FIRE_1,
	FIRE_2,
	FIRE_3,
	FIRE_4,
	LIGHTNING_1,
	LIGHTNING_2,
	LIGHTNING_3,
	LIGHTNING_4,
	PLANT_1,
	PLANT_2,
	PLANT_3,
	PLANT_4
}

var current_state = State.IDLE

var Life = 50
var max_life = 50

var Mana = 100
var max_mana = 100

@export var max_speed = 300.0
@export var acceleration = 2.5
@export var friction = 6.7

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hit_box: CollisionShape2D = $attackHitBox/collision
@onready var attack_sprite: Sprite2D = $attackHitBox/Sprite2D
@onready var attack_timer: Timer = $attackTimer
@onready var coyote_timer: Timer = $coyoteTimer

var coyote_time_activated = false

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

var damage_knockback := Vector2.ZERO

@export var knockback_force := 120.0
@export var knockback_up_force := -80.0

var current_element = -1
var imbued_element = -1

var element_colors = {
	0: Color(1.0, 0.45, 0.0),
	1: Color(0.3, 0.8, 1.0),
	2: Color(0.7, 0.2, 1.0),
	3: Color(0.3, 1.0, 0.3)
}

var spell_scenes = {
	Spell.WATER_1: preload("res://cenas_tscn/spells/water/water_1.tscn"),
	Spell.WATER_2: preload("res://cenas_tscn/spells/water/water_2.tscn"),
	Spell.WATER_3: preload("res://cenas_tscn/spells/water/water_3.tscn"),
	Spell.FIRE_1: preload("res://cenas_tscn/spells/fire/fire_1.tscn"),
	Spell.LIGHTNING_1: preload("res://cenas_tscn/spells/lightning/lightning_1.tscn"),
	Spell.PLANT_1: preload("res://cenas_tscn/spells/plant/plant_1.tscn")
}

var equipped_spells = [
	Spell.WATER_3,
	Spell.FIRE_1,
	Spell.LIGHTNING_1,
	Spell.PLANT_1
]

var active_spells = []

var selected_spell = 0

var spell_in_use = false
var active_spell = null

var spell_lock_timer: Timer

var imbue_timer: Timer


func _ready() -> void:
	add_to_group("Player")

	imbue_timer = Timer.new()
	imbue_timer.one_shot = true
	imbue_timer.timeout.connect(_on_imbue_timer_timeout)
	add_child(imbue_timer)

	spell_lock_timer = Timer.new()
	spell_lock_timer.one_shot = true
	spell_lock_timer.timeout.connect(_on_spell_lock_timer_timeout)
	add_child(spell_lock_timer)

	setup_spells()
	update_imbued_element()


func _physics_process(delta: float) -> void:
	if Life <= 0:
		current_state = State.DEAD

	if is_on_floor():
		jump_count = 0
		air_dash_available = true

	looking_up = Input.is_action_pressed("cima")
	looking_down = Input.is_action_pressed("baixo")

	handle_spell_input()

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

	if damage_knockback.length() > 10:
		velocity.x = damage_knockback.x
		velocity.y = damage_knockback.y

		damage_knockback = damage_knockback.move_toward(
			Vector2.ZERO,
			600 * delta
		)

	move_and_slide()


func setup_spells() -> void:
	active_spells.clear()

	for spell_id in equipped_spells:
		if spell_scenes.has(spell_id):
			var spell = spell_scenes[spell_id].instantiate()
			add_child(spell)
			active_spells.append(spell)
		else:
			active_spells.append(null)


func handle_spell_input() -> void:
	if Input.is_action_just_pressed("spell_1"):
		if !spell_in_use:
			selected_spell = 0
		return

	if Input.is_action_just_pressed("spell_2"):
		if !spell_in_use:
			selected_spell = 1
		return

	if Input.is_action_just_pressed("spell_3"):
		if !spell_in_use:
			selected_spell = 2
		return

	if Input.is_action_just_pressed("spell_4"):
		if !spell_in_use:
			selected_spell = 3
		return

	if Input.is_action_just_pressed("cast_spell"):
		use_selected_spell()


func use_selected_spell() -> void:
	if spell_in_use:
		return

	if selected_spell < 0:
		return

	if selected_spell >= active_spells.size():
		return

	var spell = active_spells[selected_spell]

	if spell == null:
		return

	if !spell.has_method("use"):
		return

	if spell.has_method("is_active"):
		if spell.is_active():
			return

	spell.use(self)

	if spell.has_method("is_active"):
		if !spell.is_active():
			return
	else:
		if spell.get("active") == null:
			return

		if !spell.active:
			return

	var spell_duration = spell.get("duration")

	if spell_duration == null:
		return

	if spell_duration <= 0:
		return

	spell_in_use = true
	active_spell = spell

	spell_lock_timer.start(spell_duration)


func finalizar_magia() -> void:
	spell_lock_timer.stop()
	spell_in_use = false
	active_spell = null


func _on_spell_lock_timer_timeout() -> void:
	spell_in_use = false
	active_spell = null


func equip_spell(slot: int, spell_id: int) -> void:
	if spell_in_use:
		return

	if slot < 0 or slot >= 4:
		return

	if !spell_scenes.has(spell_id):
		return

	if active_spells.size() > slot:
		var old_spell = active_spells[slot]

		if old_spell != null:
			old_spell.queue_free()

	var new_spell = spell_scenes[spell_id].instantiate()

	add_child(new_spell)

	if active_spells.size() <= slot:
		while active_spells.size() <= slot:
			active_spells.append(null)

	active_spells[slot] = new_spell
	equipped_spells[slot] = spell_id


func imbue_element(element: int, duration: float) -> void:
	imbued_element = element

	if imbue_timer:
		imbue_timer.stop()
		imbue_timer.start(duration)

	update_imbued_element()


func remove_element_imbue() -> void:
	imbued_element = -1

	if imbue_timer:
		imbue_timer.stop()

	update_imbued_element()


func update_imbued_element() -> void:
	if imbued_element == -1:
		attack_sprite.modulate = Color.WHITE
		return

	if element_colors.has(imbued_element):
		attack_sprite.modulate = element_colors[imbued_element]


func _on_imbue_timer_timeout() -> void:
	imbued_element = -1
	update_imbued_element()


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
		return

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
		return

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
		return

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


func receber_dano(dano: int, origem_x: float) -> void:
	if Life <= 0:
		return

	Life -= dano

	mostrar_dano(dano)

	var direcao = sign(global_position.x - origem_x)

	if direcao == 0:
		direcao = -1

	damage_knockback.x = direcao * knockback_force
	damage_knockback.y = knockback_up_force

	velocity = damage_knockback

	if Life <= 0:
		current_state = State.DEAD


func mostrar_dano(dano: int) -> void:
	var label = Label.new()

	label.text = str(dano)
	label.position = Vector2(-10, -45)
	label.z_index = 100

	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		label,
		"position",
		Vector2(-10, -70),
		0.5
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		0.5
	)

	tween.finished.connect(label.queue_free)


func die():
	queue_free()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigo"):
		receber_dano(1, body.global_position.x)


func _on_attack_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigo"):
		var dano = 2

		if imbued_element != -1:
			if body.has_method("_aplicar_elemento"):
				dano = body._aplicar_elemento(
					imbued_element,
					dano,
					global_position.x
				)

		body._dano(dano, global_position.x)

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
