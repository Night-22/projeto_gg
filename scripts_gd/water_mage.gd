extends Enemy

@onready var water = preload("res://cenas_tscn/ataque_agua.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var percepcao: Area2D = $percepcao
@onready var anim: AnimatedSprite2D = $anim

var player: Node2D = null
var player_na_area := false
var atacando := false
var tiro_disparado := false

@export var distancia_do_cajado := 20.0
@export var walk_speed := 40.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if player_na_area and player != null:
		Speed = 0
		
		var direcao = sign(player.global_position.x - global_position.x)
		
		if direcao != 0:
			dir = direcao
			anim.flip_h = dir > 0
		
	else:
		Speed = walk_speed
	
	super._physics_process(delta)


func _on_percepcao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	
	player = body
	player_na_area = true
	
	var direcao = sign(player.global_position.x - global_position.x)
	
	if direcao != 0:
		dir = direcao
		anim.flip_h = dir > 0
	
	if cooldown.is_stopped() and !atacando:
		atacando = true
		tiro_disparado = false
		anim.play("attack")
	else:
		anim.play("walk")


func _on_anim_frame_changed() -> void:
	if anim.animation != "attack":
		return
	
	if anim.frame == 2 and !tiro_disparado:
		tiro_disparado = true
		disparar_agua()


func _on_anim_animation_finished() -> void:
	if anim.animation == "attack":
		atacando = false
		
		if player_na_area:
			cooldown.start()
		else:
			anim.play("walk")


func disparar_agua() -> void:
	if !player_na_area or player == null:
		return
	
	var direcao = (
		player.global_position - global_position
	).normalized()
	
	var ataque = water.instantiate()
	
	ataque.global_position = global_position + direcao * distancia_do_cajado
	ataque.direction = direcao
	
	get_parent().add_child(ataque)


func _on_cooldown_timeout() -> void:
	var jogadores = percepcao.get_overlapping_bodies()
	
	for body in jogadores:
		if body.is_in_group("Player"):
			player = body
			player_na_area = true
			atacando = true
			tiro_disparado = false
			
			var direcao = sign(player.global_position.x - global_position.x)
			
			if direcao != 0:
				dir = direcao
				anim.flip_h = dir > 0
			
			anim.play("attack")
			return
	
	player = null
	player_na_area = false
	anim.play("walk")


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_na_area = false
		atacando = false
		tiro_disparado = false
		cooldown.stop()
		anim.play("walk")
