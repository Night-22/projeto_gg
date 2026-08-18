extends Area2D
class_name RaioVarreduraBoss

@export var largura := 46.0
@export var altura := 2000.0
@export var velocidade := 320.0
@export var direcao := 1.0
@export var limite_esquerdo := -100.0
@export var limite_direito := 300.0
@export var tempo_aviso := 0.35
@export var dano := 3

@onready var visual: ColorRect = $Visual
@onready var hitbox_shape: CollisionShape2D = $CollisionShape2D

var _ativo := false


func _ready() -> void:
	monitoring = false
	hitbox_shape.disabled = true

	_ajustar_tamanho()

	visual.color = Color(1.0, 0.95, 0.3, 0.35)

	await get_tree().create_timer(tempo_aviso).timeout

	if not is_instance_valid(self):
		return

	_ativar()


func _ajustar_tamanho() -> void:
	visual.size = Vector2(largura, altura)
	visual.position = Vector2(-largura / 2.0, -altura)

	if hitbox_shape.shape is RectangleShape2D:
		hitbox_shape.shape.size = Vector2(largura, altura)
		hitbox_shape.position = Vector2(0, -altura / 2.0)


func _ativar() -> void:
	visual.color = Color(1.0, 1.0, 0.85, 0.85)

	monitoring = true
	hitbox_shape.disabled = false

	_ativo = true


func _physics_process(delta: float) -> void:
	if not _ativo:
		return

	global_position.x += direcao * velocidade * delta

	var passou_esquerda := direcao < 0.0 and global_position.x < limite_esquerdo - largura
	var passou_direita := direcao > 0.0 and global_position.x > limite_direito + largura

	if passou_esquerda or passou_direita:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("receber_dano"):
		body.receber_dano(dano, global_position.x)
