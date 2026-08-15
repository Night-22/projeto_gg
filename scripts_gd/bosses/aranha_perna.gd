extends Node2D
class_name AranhaPerna

@export var espessura := 8.0

var comprimento := 300.0
var ativa := true
var atacando := false
var dano_atual := 0

@onready var visual: Sprite2D = $Visual
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	set_comprimento(comprimento)
	desativar_ataque()


func set_comprimento(valor: float) -> void:
	comprimento = valor

	#if visual:
		#visual.points = PackedVector2Array([Vector2.ZERO, Vector2(0, comprimento)])

	if hitbox_shape and hitbox_shape.shape is RectangleShape2D:
		hitbox_shape.shape.size = Vector2(espessura * 2.0, comprimento)
		hitbox_shape.position = Vector2(0, comprimento / 2.0)


func ativar_ataque(dano: int) -> void:
	if not ativa:
		return

	atacando = true
	dano_atual = dano

	if visual:
		visual.modulate = Color(0.8, 0.15, 0.15, 1.0)

	if hitbox:
		hitbox.monitoring = true


func desativar_ataque() -> void:
	atacando = false

	if visual:
		visual.modulate = Color(0, 0, 0)

	if hitbox:
		hitbox.monitoring = false


func matar_perna() -> void:
	if not ativa:
		return

	ativa = false
	desativar_ataque()
	visible = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if not atacando:
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		body.receber_dano(dano_atual, global_position.x)
