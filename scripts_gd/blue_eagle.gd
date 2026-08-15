extends Flying

@onready var water = preload("res://cenas_tscn/ataque_agua.tscn")
@onready var percepcao: Area2D = $percepcao
@onready var cooldown: Timer = $Cooldown

var player: Node2D = null
var atacando := false

@export var distancia_do_cajado := 35.0
@export var intervalo_entre_tiros := 0.15


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		
		if !atacando and cooldown.is_stopped():
			call_deferred("disparar_rajada")


func disparar_rajada() -> void:
	if !player_na_area():
		return
	
	atacando = true
	disparar_agua()
	
	await get_tree().create_timer(intervalo_entre_tiros).timeout
	if !player_na_area():
		atacando = false
		return
	
	disparar_agua()
	
	await get_tree().create_timer(intervalo_entre_tiros).timeout
	
	if !player_na_area():
		atacando = false
		return
	
	disparar_agua()
	atacando = false
	cooldown.start()


func player_na_area() -> bool:
	var jogadores = percepcao.get_overlapping_bodies()
	
	for body in jogadores:
		if body.is_in_group("Player"):
			player = body
			return true
	
	player = null
	return false


func disparar_agua() -> void:
	if !player_na_area():
		return
	
	var ataque = water.instantiate()
	var direcao = sign(
		player.global_position.x - global_position.x
	)
	if direcao == 0:
		direcao = 1
	
	ataque.global_position = global_position
	ataque.global_position.x += direcao * distancia_do_cajado
	ataque.direction = Vector2(direcao, 0)
	
	get_parent().add_child(ataque)


func _on_cooldown_timeout() -> void:
	if player_na_area() and !atacando:
		disparar_rajada()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
