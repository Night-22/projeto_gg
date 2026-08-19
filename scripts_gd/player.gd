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
	HEAL,
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


var tempo_respiracao = 20.0
var tempo_respiracao_restante = 20.0
var respiracao_ativa = false

@onready var respiracao_label = $respiracao_label


var invulnerable := false
var iframe_timer := 0.0

var input_locked := false

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
@onready var attack_sprite: AnimatedSprite2D = $attackHitBox/attack_sprite
@onready var attack_timer: Timer = $attackTimer
@onready var coyote_timer: Timer = $coyoteTimer
@onready var camera: Camera2D = $Camera2D


var dentro_da_agua := false

@export var gravidade_agua := 300.0
@export var velocidade_max_queda_agua := 100.0

@export var velocidade_agua := 110.0
@export var aceleracao_agua := 1.5

@export var jump_velocity_agua := -160.0
@export var double_jump_velocity_agua := -120.0
@export var pogo_velocity_agua := -160.0

@export var dash_speed_agua := 150.0

var camera_travada = false
var _limite_padrao_esquerdo := 0
var _limite_padrao_direito := 0
var _limite_padrao_superior := 0
var _limite_padrao_inferior := 0

var coyote_time_activated = false

var speed: float = 160.0
var jump_velocity = -310.0
var double_jump_velocity = -200.0
var pogo_velocity = -260.0

var planar_gravity = 250.0
var planar_max_fall_speed = 80.0

var last_direction = 1
var can_attack = true
var looking_up = false
var looking_down = false

var jump_count = 0
var max_jumps = 1

var dash_speed = 250.0
var dash_time = 0.2
var dash_timer = 0.0

var air_dash_available = true

var damage_knockback := Vector2.ZERO

@export var knockback_force := 200.0
@export var knockback_up_force := -100.0
@export var slime_jump_velocity = -600.0

var ladder = null
var climbing_ladder = false
var climb_speed = 120.0

var bancada = null

var tem_checkpoint := false
var respawn_position := Vector2.ZERO


var inventario_itens: Array = []

var current_element = -1
var imbued_element = -1

var element_colors = {
	0: Color(1.0, 0.45, 0.0),
	1: Color(0.0, 1.125, 10.175),
	2: Color(0.65, 0.0, 4.601),
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

var heal_mana_cost = 35
var heal_duration = 2.0
var heal_amount = 20
var heal_timer := 0.0
var heal_mana_timer := 0.0
var heal_mana_interval := 0.0
var heal_mana_spent := 0


func _ready() -> void:
	add_to_group("Player")

	respawn_position = global_position

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

	heal_mana_interval = heal_duration / float(heal_mana_cost)

	setup_spells()
	update_imbued_element()


func _physics_process(delta: float) -> void:
	if Life <= 0:
		current_state = State.DEAD
	
	if dentro_da_agua:
		atualizar_respiracao(delta)
	
	
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if current_state != State.CLIMB and current_state != State.HEAL and is_on_floor():
		jump_count = 0
		air_dash_available = true

	looking_up = Input.is_action_pressed("cima")
	looking_down = Input.is_action_pressed("baixo")

	handle_spell_input()

	if ladder != null and is_instance_valid(ladder):
		if current_state != State.CLIMB and current_state != State.HEAL:
			if Input.is_action_pressed("cima") or Input.is_action_pressed("baixo"):
				entrar_na_escada(ladder)

	if Input.is_action_just_pressed("interagir"):
		if bancada != null and is_instance_valid(bancada):
			interagir_com_bancada()

	if current_state != State.HEAL:
		tentar_iniciar_cura()

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
			if dentro_da_agua:
				current_state = State.FALL
			else:
				state_planar(delta)
				anim.play("glide")

		State.DASH:
			state_dash(delta)
			anim.play("dash")

		State.CLIMB:
			state_climb(delta)
			anim.play("climb")

		State.HEAL:
			state_heal(delta)

		State.DEAD:
			state_dead()
			anim.play("die")

	if damage_knockback.length() > 10:
		velocity.x = damage_knockback.x
		velocity.y = damage_knockback.y

	damage_knockback = damage_knockback.move_toward(
		Vector2.ZERO,
		600 * delta
	)

	move_and_slide()


func tentar_iniciar_cura() -> void:
	if !Input.is_action_pressed("curar"):
		return

	if !is_on_floor():
		return

	if Life >= max_life:
		return

	if Mana < heal_mana_cost:
		return

	if spell_in_use:
		return

	if current_state == State.ATTACK:
		return

	iniciar_cura()


func iniciar_cura() -> void:
	current_state = State.HEAL
	velocity = Vector2.ZERO

	heal_timer = 0.0
	heal_mana_timer = 0.0
	heal_mana_spent = 0


func state_heal(delta: float) -> void:
	velocity = Vector2.ZERO

	if !is_on_floor():
		cancelar_cura()
		return

	if !Input.is_action_pressed("curar"):
		cancelar_cura()
		return

	if Life >= max_life:
		cancelar_cura()
		return

	heal_timer += delta
	heal_mana_timer += delta

	while heal_mana_timer >= heal_mana_interval and heal_mana_spent < heal_mana_cost:
		heal_mana_timer -= heal_mana_interval

		if Mana <= 0:
			cancelar_cura()
			return

		Mana -= 1
		heal_mana_spent += 1

	if heal_timer >= heal_duration:
		if heal_mana_spent >= heal_mana_cost:
			Life = min(Life + heal_amount, max_life)
			finalizar_cura()
		else:
			cancelar_cura()
		return

	anim.play("idle")


func cancelar_cura() -> void:
	current_state = State.IDLE
	heal_timer = 0.0
	heal_mana_timer = 0.0
	heal_mana_spent = 0
	velocity = Vector2.ZERO


func finalizar_cura() -> void:
	current_state = State.IDLE
	heal_timer = 0.0
	heal_mana_timer = 0.0
	heal_mana_spent = 0
	velocity = Vector2.ZERO


func entrar_na_bancada(nova_bancada) -> void:
	if nova_bancada == null:
		return

	bancada = nova_bancada


func sair_da_bancada(nova_bancada) -> void:
	if bancada != nova_bancada:
		return

	bancada = null


func interagir_com_bancada() -> void:

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


func definir_checkpoint(pos: Vector2) -> void:
	tem_checkpoint = true
	respawn_position = pos


func curar_completo() -> void:
	Life = max_life
	Mana = max_mana



func morrer_e_respawnar() -> void:
	#Life = max_life
	#Mana = max_mana

	#global_position = respawn_position
	#velocity = Vector2.ZERO
	damage_knockback = Vector2.ZERO

	cancelar_cura()
	current_state = State.IDLE
	lock_player()
	anim.play("die")
	await anim.animation_finished
	var ultimo := SaveManager.obter_ultimo_save()
	if ultimo != -1:
			await SaveManager.carregar_jogo(ultimo)
	unlock_player()


func adicionar_item(id: String, nome: String, icone: String = "", quantidade: int = 1) -> void:
	for item in inventario_itens:
		if item["id"] == id:
			item["quantidade"] += quantidade
			return

	inventario_itens.append({
		"id": id,
		"nome": nome,
		"icone": icone,
		"quantidade": quantidade
	})


func remover_item(id: String, quantidade: int = 1) -> void:
	for item in inventario_itens:
		if item["id"] == id:
			item["quantidade"] -= quantidade

			if item["quantidade"] <= 0:
				inventario_itens.erase(item)

			return



func obter_dados_save() -> Dictionary:
	var cena_atual = get_tree().current_scene
	var caminho_cena = ""

	if cena_atual != null:
		caminho_cena = cena_atual.scene_file_path

	return {
		"vida": Life,
		"vida_max": max_life,
		"mana": Mana,
		"mana_max": max_mana,
		"almas_agua": almas_agua,
		"almas_fogo": almas_fogo,
		"almas_raio": almas_raio,
		"almas_planta": almas_planta,
		"magias_desbloqueadas": spell_inventory.duplicate(),
		"magias_equipadas": equipped_spells.duplicate(),
		"itens": inventario_itens.duplicate(true),
		"checkpoint_cena": caminho_cena,
		"checkpoint_pos_x": respawn_position.x,
		"checkpoint_pos_y": respawn_position.y
	}



func aplicar_dados_save(dados: Dictionary) -> void:
	Life = int(dados.get("vida", Life))
	max_life = int(dados.get("vida_max", max_life))
	Mana = int(dados.get("mana", Mana))
	max_mana = int(dados.get("mana_max", max_mana))

	almas_agua = int(dados.get("almas_agua", 0))
	almas_fogo = int(dados.get("almas_fogo", 0))
	almas_raio = int(dados.get("almas_raio", 0))
	almas_planta = int(dados.get("almas_planta", 0))

	spell_inventory.clear()

	for spell_id in dados.get("magias_desbloqueadas", []):
		spell_inventory.append(int(spell_id))

	equipped_spells.clear()

	for spell_id in dados.get("magias_equipadas", []):
		equipped_spells.append(int(spell_id))

	inventario_itens = dados.get("itens", [])

	var pos_x = float(dados.get("checkpoint_pos_x", global_position.x))
	var pos_y = float(dados.get("checkpoint_pos_y", global_position.y))

	respawn_position = Vector2(pos_x, pos_y)
	tem_checkpoint = true

	global_position = respawn_position

	rebuild_active_spells()


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
		if is_on_floor():
			anim.play("ataque_chao")
		else:
			anim.play("ataque_ar")
		use_selected_spell()


func use_selected_spell() -> void:
	if spell_in_use:
		return

	if current_state == State.HEAL:
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
		direction * obter_speed(),
		delta * obter_acceleration()
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
	aplicar_gravidade(delta)

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * obter_speed(),
		delta * obter_acceleration()
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
	aplicar_gravidade(delta)

	var direction := Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

	anim.flip_h = last_direction < 0

	if direction != 0:
		last_direction = direction

	velocity.x = lerp(
		velocity.x,
		direction * obter_speed(),
		delta * obter_acceleration()
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
	create_dash_effect()

	velocity.y = 0
	velocity.x = obter_dash_speed() * last_direction

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
		anim.play("climb")
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
	#velocity += get_gravity() * get_physics_process_delta_time()
	die()

func jump():
	if jump_count >= max_jumps:
		return

	if jump_count == 0:
		velocity.y = obter_jump_velocity()
	else:
		velocity.y = obter_double_jump_velocity()

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
			attack_hit_box.position = Vector2(25, 0)
			attack_hit_box.rotation = -1.57079633
			attack_sprite.position = Vector2(10, 0)
			attack_sprite.rotation = 0
			attack_sprite.play("attack_side")

		"left":
			anim.flip_h = true
			attack_sprite.flip_h = true
			attack_hit_box.position = Vector2(-25, 0)
			attack_hit_box.rotation = -1.57079633
			attack_sprite.position = Vector2(-10, 0)
			attack_sprite.rotation = 0
			attack_sprite.play("attack_side")

		"up":
			attack_sprite.flip_h = false
			attack_hit_box.position = Vector2(0, -20)
			attack_hit_box.rotation = -1.57079633
			attack_sprite.position = Vector2(-8, -20)
			attack_sprite.rotation = 0
			attack_sprite.play("attack_up_down")

		"down":
			attack_sprite.flip_h = false
			attack_hit_box.position = Vector2(0, 20)
			attack_hit_box.rotation = 1.57079633
			attack_sprite.position = Vector2(8, 20)
			attack_sprite.rotation = 3
			attack_sprite.play("attack_up_down")


func receber_dano(dano: int, origem_x: float) -> void:
	if Life <= 0 or invulnerable:
		return

	iniciar_iframe()

	tremer_camera(5, 0.25)

	if current_state == State.HEAL:
		cancelar_cura()

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
	morrer_e_respawnar()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body is Totem_alavanca:
		return
	
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
			velocity.y = obter_pogo_velocity()
			jump_count = min(jump_count + 1, max_jumps)
			air_dash_available = true
			current_state = State.JUMP

func fazer_pogo() -> void:
	print("PLAYER: POGO EXECUTADO")

	velocity.y = obter_pogo_velocity()
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


func pular_no_slime():
	velocity.y = slime_jump_velocity
	jump_count = 1
	air_dash_available = true
	current_state = State.JUMP


var area_camera_atual = null

func travar_camera(area: Rect2, origem = null) -> void:
	area_camera_atual = origem

	camera_travada = true

	camera.limit_left = int(area.position.x)
	camera.limit_top = int(area.position.y)
	camera.limit_right = int(area.position.x + area.size.x)
	camera.limit_bottom = int(area.position.y + area.size.y)


func destravar_camera(origem = null) -> void:
	if area_camera_atual != null and origem != area_camera_atual:
		return

	area_camera_atual = null
	camera_travada = false

	camera.limit_left = _limite_padrao_esquerdo
	camera.limit_top = _limite_padrao_superior
	camera.limit_right = _limite_padrao_direito
	camera.limit_bottom = _limite_padrao_inferior
	
func lock_player() -> void:
	input_locked = true
	velocity = Vector2.ZERO
	damage_knockback = Vector2.ZERO


func unlock_player() -> void:
	input_locked = false
	
func tremer_camera(intensidade: float = 5.0, duracao: float = 0.15) -> void:
	var tween = create_tween()

	var quantidade_tremores := int(duracao / 0.03)

	for i in quantidade_tremores:
		tween.tween_property(
			camera,
			"offset",
			Vector2(
				randf_range(-intensidade, intensidade),
				randf_range(-intensidade, intensidade)
			),
			0.03
		)

	tween.tween_property(
		camera,
		"offset",
		Vector2.ZERO,
		0.05
	)

var freeze_tween: Tween

#func freeze_time(duracao: float = 0.1) -> void:
	#Engine.time_scale = 0.0
	#
	#await get_tree().create_timer(
		#duracao,
		#true,
		#false,
		#true
	#).timeout
	#
	#Engine.time_scale = 1.0
	
func create_dash_effect():
	var playerCopyNode = anim.duplicate()
	get_parent().add_child(playerCopyNode)
	playerCopyNode.global_position = global_position
	playerCopyNode.modulate.a = 0.0

	var animationTime = dash_timer / 2.0

	var tween = create_tween()
	tween.tween_property(
		playerCopyNode,
		"modulate:a",
		0.5,
		animationTime * 0.3
	)
	tween.tween_property(
		playerCopyNode,
		"modulate:a",
		0.0,
		animationTime * 0.7
	)

	await tween.finished
	playerCopyNode.queue_free()

func iniciar_iframe(duracao: float = 0.7) -> void:
	if invulnerable:
		return

	invulnerable = true
	iframe_timer = duracao

	

	while iframe_timer > 0:
		iframe_timer -= get_physics_process_delta_time()

		modulate.a = 0.4 if int(iframe_timer * 20.0) % 2 == 0 else 1.0

		await get_tree().physics_frame

	

	invulnerable = false
	modulate.a = 1.0

func entrar_na_agua() -> void:
	dentro_da_agua = true


func sair_da_agua() -> void:
	dentro_da_agua = false
	resetar_tempo_respirar()
	
func obter_speed() -> float:
	if dentro_da_agua:
		return velocidade_agua

	return speed


func obter_acceleration() -> float:
	if dentro_da_agua:
		return aceleracao_agua

	return acceleration


func obter_jump_velocity() -> float:
	if dentro_da_agua:
		return jump_velocity_agua

	return jump_velocity


func obter_double_jump_velocity() -> float:
	if dentro_da_agua:
		return double_jump_velocity_agua

	return double_jump_velocity


func obter_pogo_velocity() -> float:
	if dentro_da_agua:
		return pogo_velocity_agua

	return pogo_velocity


func obter_dash_speed() -> float:
	if dentro_da_agua:
		return dash_speed_agua

	return dash_speed


func aplicar_gravidade(delta: float) -> void:
	if dentro_da_agua:
		velocity.y += gravidade_agua * delta
		velocity.y = min(velocity.y, velocidade_max_queda_agua)
	else:
		velocity += get_gravity() * delta





func atualizar_respiracao(delta: float) -> void:
	if !respiracao_ativa:
		respiracao_ativa = true

	var velocidade_tempo = 1.0

	# depois de 5 segundos, fica 2 vezes mais lento
	if tempo_respiracao_restante <= 5.0:
		velocidade_tempo = 0.5
		respiracao_label.visible = true

		# faz a label piscar
		respiracao_label.modulate.a = 0.5 + abs(sin(Time.get_ticks_msec() * 0.008)) * 0.5

	tempo_respiracao_restante -= delta * velocidade_tempo
	tempo_respiracao_restante = max(tempo_respiracao_restante, 0.0)

	respiracao_label.text = str(ceil(tempo_respiracao_restante))

	if tempo_respiracao_restante <= 0.0:
		current_state = State.DEAD
		
		
func resetar_tempo_respirar() -> void:
	tempo_respiracao_restante = tempo_respiracao
	respiracao_ativa = false

	respiracao_label.visible = false
	respiracao_label.modulate.a = 1.0
