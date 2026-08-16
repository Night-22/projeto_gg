extends Enemy

@onready var wave = preload("res://cenas_tscn/firewall.tscn")
@onready var percepcao: Area2D = $percepcao
@onready var cooldown: Timer = $Cooldown

var player: Node2D = null
var primeiro_ataque := true
var firewall: Node2D = null

@export var distancia_do_ataque := 40.0
@export var velocidade_normal := 40.0


func _on_percepcao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	
	player = body
	
	if primeiro_ataque:
		primeiro_ataque = false
		call_deferred("disparar_onda")


func disparar_onda() -> void:
	if player == null or firewall != null:
		return
	
	var direcao = sign(player.global_position.x - global_position.x)
	
	if direcao == 0:
		direcao = dir
	
	firewall = wave.instantiate()
	firewall.global_position = global_position + Vector2(direcao * distancia_do_ataque, 0)
	firewall.direction = direcao
	
	get_parent().add_child(firewall)
	
	Speed = 0
	cooldown.start()


func _on_cooldown_timeout() -> void:
	if firewall != null:
		firewall.queue_free()
		firewall = null
	
	Speed = velocidade_normal
	
	var jogadores = percepcao.get_overlapping_bodies()
	
	for body in jogadores:
		if body.is_in_group("Player"):
			player = body
			disparar_onda()
			return
	
	player = null


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
