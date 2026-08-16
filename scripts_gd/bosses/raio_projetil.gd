extends Area2D
class_name RaioProjetil

@export var largura := 50.0
@export var altura := 130.0
@export var tempo_aviso := 0.4
@export var tempo_ativo := 0.25
@export var dano := 4

@onready var visual: ColorRect = $Visual
@onready var hitbox_shape: CollisionShape2D = $CollisionShape2D

var _atingiu := false


func _ready() -> void:
	monitoring = false
	hitbox_shape.disabled = true

	_ajustar_tamanho()

	visual.color = Color(1.0, 0.95, 0.3, 0.35)

	await get_tree().create_timer(tempo_aviso).timeout

	if not is_instance_valid(self):
		return

	_ativar_golpe()


func _ajustar_tamanho() -> void:
	visual.size = Vector2(largura, altura)
	visual.position = Vector2(-largura / 2.0, -altura)

	if hitbox_shape.shape is RectangleShape2D:
		hitbox_shape.shape.size = Vector2(largura, altura)
		hitbox_shape.position = Vector2(0, -altura / 2.0)


func _ativar_golpe() -> void:
	visual.color = Color(1.0, 1.0, 0.85, 0.85)

	monitoring = true
	hitbox_shape.disabled = false

	await get_tree().create_timer(tempo_ativo).timeout

	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _atingiu:
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		_atingiu = true
		body.receber_dano(dano, global_position.x)
