extends Node2D

@onready var ray_cast = get_node("RayCast2D")
@onready var timer = get_node("Timer")
@onready var bala = preload("res://cenas_tscn/prefabs/bala_torreta.tscn")
@onready var sprite_cima = get_node("parte_cima")
@onready var area = get_node("percepcao")

var player
var player_na_area := false


func _ready() -> void:
	player = get_parent().find_child("Player")


func _physics_process(_delta: float) -> void:
	mirar()
	checar_player_colisao()


func mirar():
	ray_cast.target_position = to_local(player.position)
	sprite_cima.rotation = global_position.angle_to_point(player.global_position)


func checar_player_colisao():
	if player_na_area and ray_cast.get_collider() == player and timer.is_stopped():
		timer.start()

	elif (not player_na_area or ray_cast.get_collider() != player) and not timer.is_stopped():
		timer.stop()


func _on_timer_timeout() -> void:
	if player_na_area and ray_cast.get_collider() == player:
		atirar()


func atirar():
	var bala_instancia = bala.instantiate()
	bala_instancia.position = position
	bala_instancia.direcao = (ray_cast.target_position).normalized()
	get_tree().current_scene.add_child(bala_instancia)

	var posicao_original = sprite_cima.position
	var direcao = Vector2.RIGHT.rotated(sprite_cima.rotation)
	var posicao_recuada = posicao_original - direcao * 3.0

	var tween := create_tween()
	tween.tween_property(sprite_cima, "position", posicao_recuada, 0.05)
	tween.tween_property(sprite_cima, "position", posicao_original, 0.1)


#func _on_percepcao_body_entered(body):
	#if body == player:
		#player_na_area = true
#
#
#func _on_percepcao_body_exited(body):
	#if body == player:
		#player_na_area = false


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	player_na_area = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	player_na_area = false
