extends Enemy

@onready var water = preload("res://cenas_tscn/ataque_planta.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var percepcao: Area2D = $percepcao

var player: Node2D = null
var player_na_area := false

@export var distancia_do_cajado := 35.0


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_na_area = true
		
		if cooldown.is_stopped():
			call_deferred("disparar_agua")


func disparar_agua() -> void:
	if !player_na_area or player == null:
		return
	
	var ataque = water.instantiate()
	var direcao = (
		player.global_position - global_position
	).normalized()

	ataque.global_position = global_position + direcao * distancia_do_cajado
	ataque.direction = direcao
	
	get_parent().add_child(ataque)

	cooldown.start()


func _on_cooldown_timeout() -> void:
	var jogadores = percepcao.get_overlapping_bodies()
	
	for body in jogadores:
		if body.is_in_group("Player"):
			player = body
			player_na_area = true
			disparar_agua()
			return
	
	player = null
	player_na_area = false
	cooldown.stop()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
		player_na_area = false
		cooldown.stop()
