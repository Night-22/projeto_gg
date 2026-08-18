extends Flying

@onready var water = preload("res://cenas_tscn/ataque_raio.tscn")
@onready var cooldown: Timer = $Cooldown
@onready var percepcao: Area2D = $percepcao

var player: Node2D = null
var atacando := false
var ja_atacou := false

@export var distancia_do_ataque := 10.0
@export var angulo_dos_tiros := 40.0


func _on_percepcao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	
	player = body
	
	if !ja_atacou and !atacando:
		ja_atacou = true
		call_deferred("disparar_rajada")


func disparar_rajada() -> void:
	if !player_esta_na_percepcao():
		return
	
	atacando = true
	
	var direcao = player.global_position - global_position
	var angulo = direcao.angle()
	var abertura = deg_to_rad(angulo_dos_tiros)
	
	disparar_agua(Vector2.from_angle(angulo - abertura))
	disparar_agua(Vector2.from_angle(angulo))
	disparar_agua(Vector2.from_angle(angulo + abertura))
	
	atacando = false
	cooldown.start()


func disparar_agua(direcao: Vector2) -> void:
	var ataque = water.instantiate()
	
	ataque.global_position = global_position + direcao * distancia_do_ataque
	ataque.direction = direcao
	
	get_parent().add_child(ataque)


func player_esta_na_percepcao() -> bool:
	for body in percepcao.get_overlapping_bodies():
		if body.is_in_group("Player"):
			player = body
			return true
	
	player = null
	return false


func _on_cooldown_timeout() -> void:
	if player_esta_na_percepcao() and !atacando:
		disparar_rajada()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		atacando = false
