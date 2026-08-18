extends Area2D
class_name Bolha

enum Direcao {
	CIMA,
	BAIXO
}

@onready var sprite = get_node("Sprite2D")
@onready var collision_shape = get_node("CollisionShape2D")

@export var quantidade_sprites = 10
@export var velocidade = 40.0
@export var intervalo_spawn: float = 0.2
@export var direcao: Direcao = Direcao.CIMA


func _ready() -> void:
	sprite.visible = false
	
	for i in quantidade_sprites:
		criar_sprite()
		await get_tree().create_timer(intervalo_spawn).timeout

	while true:
		criar_sprite()
		await get_tree().create_timer(intervalo_spawn).timeout


func criar_sprite() -> void:
	var novo_sprite = sprite.duplicate()
	novo_sprite.visible = true
	novo_sprite.modulate.a = 1.0
	novo_sprite.scale = Vector2(0.5, 0.5)

	add_child(novo_sprite)

	var shape = collision_shape.shape as RectangleShape2D
	if shape == null:
		return

	var tamanho = shape.size / 2.0

	var baixo = collision_shape.position.y + tamanho.y
	var topo = collision_shape.position.y - tamanho.y
	var esquerda = collision_shape.position.x - tamanho.x
	var direita = collision_shape.position.x + tamanho.x

	var inicio_y: float
	var fim_y: float

	if direcao == Direcao.CIMA:
		inicio_y = baixo
		fim_y = topo
	else:
		inicio_y = topo
		fim_y = baixo

	novo_sprite.position = Vector2(
		randf_range(esquerda, direita),
		inicio_y
	)

	var duracao = abs(fim_y - inicio_y) / velocidade

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(novo_sprite, "position:y", fim_y, duracao)
	tween.tween_property(novo_sprite, "modulate:a", 0.0, duracao)
	tween.tween_property(novo_sprite, "scale", Vector2(1.0, 1.0), duracao * 0.2)
	tween.tween_property(novo_sprite, "scale", Vector2(0.7, 0.7), duracao * 0.3).set_delay(duracao * 0.7)

	tween.set_parallel(false)
	tween.tween_callback(remover_sprite.bind(novo_sprite))


func remover_sprite(novo_sprite: Sprite2D) -> void:
	if is_instance_valid(novo_sprite):
		novo_sprite.queue_free()
