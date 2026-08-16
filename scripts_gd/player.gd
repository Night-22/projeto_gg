extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	FALL,
	PLANAR,
	DASH,
	CLIMB,
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

var Mana = 500
var max_mana = 500

var almas_agua = 0
var almas_fogo = 0
var almas_raio = 0
var almas_planta = 0

@export var max_speed = 200.0
@export var acceleration = 2.5
@export var friction = 6.7

@onready var anim: AnimatedSprite2D = $anim
@onready var attack_hit_box: CollisionShape2D = $attackHitBox/collision
@onready var attack_sprite: Sprite2D = $attackHitBox/Sprite2D
@onready var attack_timer: Timer = $attackTimer
@onready var coyote_timer: Timer = $coyoteTimer
@onready var camera: Camera2D = $Camera2D

var camera_travada = false
var _limite_padrao_esquerdo := 0
var _limite_padrao_direito := 0
var _limite_padrao_superior := 0
var _limite_padrao_inferior := 0

var coyote_time_activated = false

var speed: float = 200.0
var jump_velocity = -360.0
var double_jump_velocity = -280.0
var pogo_velocity = -360.0

var planar_gravity = 250.0
var planar_max_fall_speed = 80.0

var last_direction = 1
var can_attack = true
var looking_up = false
var looking_down = false

var jump_count = 0
var max_jumps = 2

var dash_speed = 250.0
var dash_time = 0.2
var dash_timer = 0.0

var air_dash_available = true

var damage_knockback := Vector2.ZERO

@export var knockback_force := 200.0
@export var knockback_up_force := -100.0

var ladder = null
var climbing_ladder = false
var climb_speed = 120.0

var bancada = null

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
	Spell.WATER_4: preload("res://cenas_tscn/spells/water/water_4.tscn"),
	Spell.FIRE_1: preload("res://cenas_tscn/spells/fire/fire_1.tscn"),
	Spell.FIRE_2: preload("res://cenas_tscn/spells/fire/fire_2.tscn"),
	Spell.FIRE_3: preload("res://cenas_tscn/spells/fire/fire_3.tscn"),
	Spell.FIRE_4: preload("res://cenas_tscn/spells/fire/fire_4.tscn"),
	Spell.LIGHTNING_1: preload("res://cenas_tscn/spells/lightning/lightning_1.tscn"),
	Spell.LIGHTNING_2: preload("res://cenas_tscn/spells/lightning/lightning_2.tscn"),
	Spell.LIGHTNING_3: preload("res://cenas_tscn/spells/lightning/lightning_3.tscn"),
	Spell.LIGHTNING_4: preload("res://cenas_tscn/spells/lightning/lightning_4.tscn"),
	Spell.PLANT_1: preload("res://cenas_tscn/spells/plant/plant_1.tscn"),
	Spell.PLANT_2: preload("res://cenas_tscn/spells/plant/plant_2.tscn"),
	Spell.PLANT_3: preload("res://cenas_tscn/spells/plant/plant_3.tscn"),
	Spell.PLANT_4: preload("res://cenas_tscn/spells/plant/plant_4.tscn")
}

var equipped_spells = [
	Spell.WATER_4,
	Spell.FIRE_4,
	Spell.LIGHTNING_4,
	Spell.PLANT_3
]

var spell_inventory = [
	Spell.WATER_1,
	Spell.WATER_2,
	Spell.WATER_3,
	Spell.WATER_4
]

var all_spells = [
	Spell.WATER_1,
	Spell.WATER_2,
	Spell.WATER_3,
	Spell.WATER_4,
	Spell.FIRE_1,
	Spell.FIRE_2,
	Spell.FIRE_3,
	Spell.FIRE_4,
	Spell.LIGHTNING_1,
	Spell.LIGHTNING_2,
	Spell.LIGHTNING_3,
	Spell.LIGHTNING_4,
	Spell.PLANT_1,
	Spell.PLANT_2,
	Spell.PLANT_3,
	Spell.PLANT_4
]

var spell_costs = {
	Spell.WATER_1: 2,
	Spell.WATER_2: 4,
	Spell.WATER_3: 6,
	Spell.WATER_4: 10,
	Spell.FIRE_1: 2,
	Spell.FIRE_2: 4,
	Spell.FIRE_3: 6,
	Spell.FIRE_4: 10,
	Spell.LIGHTNING_1: 2,
	Spell.LIGHTNING_2: 4,
	Spell.LIGHTNING_3: 6,
	Spell.LIGHTNING_4: 10,
	Spell.PLANT_1: 2,
	Spell.PLANT_2: 4,
	Spell.PLANT_3: 6,
	Spell.PLANT_4: 10
}

var active_spells = []
var selected_spell = 0
var spell_in_use = false
var active_spell = null
var spell_lock_timer: Timer
var imbue_timer: Timer
var plataforma_timer: Timer


func _ready() -> void:
	add_to_group("Player")

	_limite_padrao_esquerdo = camera.limit_left
	_limite_padrao_direito = camera.limit_right
	_limite_padrao_superior = camera.limit_top
	_limite_padrao_inferior = camera.limit_bottom

	imbue_timer = Timer.new()
	imbue_timer.one_shot = true
	imbue_timer.timeout.connect(_on_imbue_timer_timeout)
	add_child(imbue_timer)

	spell_lock_timer = Timer.new()
	spell_lock_timer.one_shot = true
	spell_lock_timer.timeout.connect(_on_spell_lock_timer_timeout)
	add_child(spell_lock_timer)

	plataforma_timer = Timer.new()
	plataforma_timer.one_shot = true
	plataforma_timer.timeout.connect(_on_plataforma_timer_timeout)
	add_child(plataforma_timer)

	setup_spells()
	update_imbued_element()


func _physics_process(delta: float) -> void:
	if Life <= 0:
		current_state = State.DEAD

	if current_state != State.CLIMB and is_on_floor():
		jump_count = 0
		air_dash_available = true

	looking_up = Input.is_action_pressed("cima")
	looking_down = Input.is_action_pressed("baixo")

	handle_spell_input()

	if ladder != null and is_instance_valid(ladder):
		if current_state != State.CLIMB:
			if Input.is_action_pressed("cima") or Input.is_action_pressed("baixo"):
				entrar_na_escada(ladder)

	if Input.is_action_just_pressed("interagir"):
		if bancada != null and is_instance_valid(bancada) :
			interagir_com_bancada()



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

		State.PLANAR:
			state_planar(delta)
			anim.play("fall")

		State.DASH:
			state_dash(delta)

		State.CLIMB:
			state_climb(delta)

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

func entrar_na_bancada(nova_bancada) -> void:
	if nova_bancada == null:
		return

	bancada = nova_bancada


func sair_da_bancada(nova_bancada) -> void:
	if bancada != nova_bancada:
		return

	bancada = null


func interagir_com_bancada() -> void:
	print('bancada')
	if bancada == null:
		return

	if !is_instance_valid(bancada):
		bancada = null
		return

	if bancada.has_method("interagir"):
		bancada.interagir()


func adicionar_alma(tipo_alma: int) -> void:
	match tipo_alma:
		0:
			almas_agua += 1
			print("almas de agua: ", almas_agua)

		1:
			almas_fogo += 1
			print("almas de fogo: ", almas_fogo)

		2:
			almas_raio += 1
			print("almas de raio: ", almas_raio)

		3:
			almas_planta += 1
			print("almas de planta: ", almas_planta)


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

	if selected_spell < 0 or selected_spell >= equipped_spells.size():
		return

	if selected_spell >= active_spells.size():
		setup_spells()

	if selected_spell >= active_spells.size():
		return

	var spell = active_spells[selected_spell]

	if spell == null or !is_instance_valid(spell):
		setup_spells()
		spell = active_spells[selected_spell]

	if spell == null:
		return

	if !spell.has_method("use"):
		return

	var mana_before = Mana

	spell.use(self)

	if Mana == mana_before:
		return

	var spell_duration = spell.get("duration")

	if spell_duration == null:
		spell_duration = 0.0

	if spell_duration > 0:
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

	if spell_id not in spell_inventory:
		return

	if active_spells.size() > slot:
		var old_spell = active_spells[slot]

		if old_spell != null:
			old_spell.queue_free()

	var new_spell = spell_scenes[spell_id].instantiate()
	add_child(new_spell)

	while active_spells.size() <= slot:
		active_spells.append(null)

	active_spells[slot] = new_spell
	equipped_spells[slot] = spell_id


func rebuild_active_spells() -> void:
	for spell in active_spells:
		if spell != null and is_instance_valid(spell):
			spell.queue_free()

	active_spells.clear()

	await get_tree().process_frame

	for spell_id in equipped_spells:
		if spell_scenes.has(spell_id):
			var spell = spell_scenes[spell_id].instantiate()
			add_child(spell)
			active_spells.append(spell)
		else:
			active_spells.append(null)

	if selected_spell >= active_spells.size():
		selected_spell = 0


func desbloquear_magia(spell_id: int) -> bool:
	if !spell_scenes.has(spell_id):
		return false

	if spell_id in spell_inventory:
		return false

	spell_inventory.append(spell_id)

	return true


func magia_desbloqueada(spell_id: int) -> bool:
	return spell_id in spell_inventory


func obter_elemento_da_magia(spell_id: int) -> int:
	if spell_id >= Spell.WATER_1 and spell_id <= Spell.WATER_4:
		return 1

	if spell_id >= Spell.FIRE_1 and spell_id <= Spell.FIRE_4:
		return 0

	if spell_id >= Spell.LIGHTNING_1 and spell_id <= Spell.LIGHTNING_4:
		return 2

	if spell_id >= Spell.PLANT_1 and spell_id <= Spell.PLANT_4:
		return 3

	return -1


func obter_custo_da_magia(spell_id: int) -> int:
	if !spell_costs.has(spell_id):
		return 0

	return spell_costs[spell_id]


func obter_almas_do_elemento(elemento: int) -> int:
	match elemento:
		0:
			return almas_fogo

		1:
			return almas_agua

		2:
			return almas_raio

		3:
			return almas_planta

	return 0


func remover_almas_do_elemento(elemento: int, quantidade: int) -> bool:
	if quantidade <= 0:
		return false

	if obter_almas_do_elemento(elemento) < quantidade:
		return false

	match elemento:
		0:
			almas_fogo -= quantidade

		1:
			almas_agua -= quantidade

		2:
			almas_raio -= quantidade

		3:
			almas_planta -= quantidade

		_:
			return false

	return true


func pode_craftar_magia(spell_id: int) -> bool:
	if !spell_scenes.has(spell_id):
		return false

	if spell_id in spell_inventory:
		return false

	var elemento = obter_elemento_da_magia(spell_id)

	if elemento == -1:
		return false

	var custo = obter_custo_da_magia(spell_id)

	if custo <= 0:
		return false

	return obter_almas_do_elemento(elemento) >= custo


func craftar_magia(spell_id: int) -> bool:
	if !pode_craftar_magia(spell_id):
		return false

	var elemento = obter_elemento_da_magia(spell_id)
	var custo = obter_custo_da_magia(spell_id)

	if !remover_almas_do_elemento(elemento, custo):
		return false

	if !desbloquear_magia(spell_id):
		return false

	return true


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
		if looking_down and esta_em_plataforma_furavel():
			descer_plataforma()
			return

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
		if looking_down and esta_em_plataforma_furavel():
			descer_plataforma()
			return

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

	if velocity.y < 0 and Input.is_action_just_released("pulo"):
		velocity.y *= jump_force

	if velocity.y >= 0:
		if jump_count >= max_jumps and Input.is_action_pressed("pulo"):
			current_state = State.PLANAR
			return

		current_state = State.FALL

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK


func state_attack(_delta):
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

	if jump_count >= max_jumps and Input.is_action_pressed("pulo"):
		current_state = State.PLANAR
		return

	if is_on_floor():
		coyote_time_activated = false
		coyote_timer.stop()

		if direction == 0:
			current_state = State.IDLE
		else:
			current_state = State.WALK


func state_planar(delta):
	velocity.y += planar_gravity * delta
	velocity.y = min(velocity.y, planar_max_fall_speed)

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * speed,
		delta * acceleration
	)

	if !Input.is_action_pressed("pulo"):
		current_state = State.FALL
		return

	if Input.is_action_just_pressed("ataque"):
		current_state = State.ATTACK
		return

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return

	if is_on_floor():
		jump_count = 0
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


func state_climb(_delta):
	if ladder == null or !is_instance_valid(ladder):
		climbing_ladder = false
		current_state = State.FALL
		return

	climbing_ladder = true

	var centro_escada = ladder.global_position.x

	global_position.x = lerp(
		global_position.x,
		centro_escada,
		0.35
	)

	velocity.x = 0
	velocity.y = 0

	var vertical_direction := 0.0

	if Input.is_action_pressed("cima"):
		vertical_direction -= 1.0

	if Input.is_action_pressed("baixo"):
		vertical_direction += 1.0

	velocity.y = vertical_direction * climb_speed

	if vertical_direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")

	if Input.is_action_just_pressed("pulo"):
		climbing_ladder = false
		jump()
		return

	if Input.is_action_pressed("esquerda") or Input.is_action_pressed("direita"):
		climbing_ladder = false
		current_state = State.FALL
		return


func state_dead():
	die()


func jump():
	if jump_count >= max_jumps:
		return

	if jump_count == 0:
		velocity.y = jump_velocity
	else:
		velocity.y = double_jump_velocity

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


func entrar_na_escada(nova_escada) -> void:
	if nova_escada == null:
		return

	ladder = nova_escada

	if Input.is_action_pressed("cima") or Input.is_action_pressed("baixo"):
		climbing_ladder = true
		current_state = State.CLIMB
		velocity = Vector2.ZERO
		global_position.x = ladder.global_position.x


func sair_da_escada(escada) -> void:
	if ladder != escada:
		return

	if current_state == State.CLIMB:
		climbing_ladder = false

		if is_on_floor():
			current_state = State.IDLE
		else:
			current_state = State.FALL

	ladder = null


func esta_em_plataforma_furavel() -> bool:
	for i in get_slide_collision_count():
		var colisao := get_slide_collision(i)

		if colisao.get_collider() and colisao.get_collider().is_in_group("PlataformaFuravel"):
			return true

	return false


func descer_plataforma() -> void:
	set_collision_mask_value(2, false)
	plataforma_timer.start(0.25)
	current_state = State.FALL


func _on_plataforma_timer_timeout() -> void:
	set_collision_mask_value(2, true)


func attack_to_direction(dir):
	match dir:
		"right":
			anim.flip_h = false
			attack_sprite.flip_h = false
			attack_hit_box.position = Vector2(15, 0)
			attack_hit_box.rotation = 0
			attack_sprite.position = Vector2(15, 0)
			attack_sprite.rotation = 0

		"left":
			anim.flip_h = true
			attack_sprite.flip_h = true
			attack_hit_box.position = Vector2(-15, 0)
			attack_hit_box.rotation = 0
			attack_sprite.position = Vector2(-15, 0)
			attack_sprite.rotation = 0

		"up":
			attack_sprite.flip_h = false
			attack_hit_box.position = Vector2(0, -20)
			attack_hit_box.rotation = -1.57079633
			attack_sprite.position = Vector2(0, -20)
			attack_sprite.rotation = -1.57079633

		"down":
			attack_sprite.flip_h = false
			attack_hit_box.position = Vector2(0, 20)
			attack_hit_box.rotation = 1.57079633
			attack_sprite.position = Vector2(0, 20)
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
	if body is Enemy:
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

		Mana = min(Mana + 10, max_mana)

		if looking_down and !is_on_floor():
			velocity.y = pogo_velocity
			jump_count = min(jump_count + 1, max_jumps)
			air_dash_available = true
			current_state = State.JUMP


func _on_coyote_timer_timeout() -> void:
	coyote_time_activated = false

	if !is_on_floor() and jump_count == 0:
		jump_count = 1


func _on_attack_timer_timeout() -> void:
	can_attack = true
	attack_sprite.visible = false
	attack_hit_box.disabled = true

func travar_camera(area: Rect2) -> void:
	camera_travada = true

	camera.limit_left = int(area.position.x)
	camera.limit_top = int(area.position.y)
	camera.limit_right = int(area.position.x + area.size.x)
	camera.limit_bottom = int(area.position.y + area.size.y)


func destravar_camera() -> void:
	camera_travada = false

	camera.limit_left = _limite_padrao_esquerdo
	camera.limit_top = _limite_padrao_superior
	camera.limit_right = _limite_padrao_direito
	camera.limit_bottom = _limite_padrao_inferior
