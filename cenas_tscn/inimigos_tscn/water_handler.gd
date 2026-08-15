extends Enemy

@onready var wave = preload("res://cenas_tscn/wave.tscn")
@onready var percepcao: Area2D = $percepcao
@onready var cooldown: Timer = $Cooldown

var player: Node2D = null
var primeiro_ataque := true

@export var distancia_do_ataque := 40.0


func _on_percepcao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		
		# Só ataca imediatamente na primeira vez
		if primeiro_ataque:
			primeiro_ataque = false
			call_deferred("disparar_onda")


func disparar_onda() -> void:
	if player == null:
		return
	
	var ataque = wave.instantiate()
	
	var direcao = sign(
		player.global_position.x - global_position.x
	)
	
	if direcao == 0:
		direcao = 1
	
	ataque.global_position = global_position
	ataque.global_position.x += direcao * distancia_do_ataque
	ataque.direction = direcao
	
	get_parent().add_child(ataque)
	
	cooldown.start()


func _on_cooldown_timeout() -> void:
	var jogadores = percepcao.get_overlapping_bodies()
	
	for body in jogadores:
		if body.is_in_group("Player"):
			player = body
			disparar_onda()
			return
	
	player = null


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = null
