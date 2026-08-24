extends StaticBody2D
class_name PortaElemental

signal aberta

@export var area_transicao_path: NodePath

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var area_deteccao: Area2D = $Area2D

@onready var icone_fogo: Sprite2D = $Icones/IconeFogo
@onready var icone_agua: Sprite2D = $Icones/IconeAgua
@onready var icone_raio: Sprite2D = $Icones/IconeRaio
@onready var icone_planta: Sprite2D = $Icones/IconePlanta

@onready var area_transicao: Area2D = get_node_or_null(area_transicao_path)

var posicao_inicial: Vector2
var jogador_perto := false
var porta_aberta := false

var player: Node = null


func _ready() -> void:
	posicao_inicial = position
	sprite.play("fechada")

	icone_fogo.visible = false
	icone_agua.visible = false
	icone_raio.visible = false
	icone_planta.visible = false

	if area_transicao != null:
		area_transicao.monitoring = false


func _physics_process(_delta: float) -> void:
	if porta_aberta:
		return

	if player == null or !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if not player.has_method("possui_medalhao"):
		return

	# 0 = fogo, 1 = agua, 2 = raio, 3 = planta 
	icone_fogo.visible = player.possui_medalhao(0)
	icone_agua.visible = player.possui_medalhao(1)
	icone_raio.visible = player.possui_medalhao(2)
	icone_planta.visible = player.possui_medalhao(3)

	if jogador_perto and Input.is_action_just_pressed("interagir"):
		if todos_medalhoes_presentes():
			abrir()


func todos_medalhoes_presentes() -> bool:
	if player == null or !player.has_method("possui_medalhao"):
		return false

	return (
		player.possui_medalhao(0)
		and player.possui_medalhao(1)
		and player.possui_medalhao(2)
		and player.possui_medalhao(3)
	)


func abrir() -> void:
	if porta_aberta:
		return

	porta_aberta = true
	sprite.play("aberta")
	colisao.disabled = true

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"position:y",
		posicao_inicial.y - 80,
		1.0
	)
	
	tween.parallel().tween_property(
		sprite,
		"modulate:a",
		0.0,
		1.0
	)
	
	tween.tween_callback(_liberar_passagem)
	
	aberta.emit()
	
func _liberar_passagem() -> void:
	if area_transicao != null:
		area_transicao.monitoring = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = false
