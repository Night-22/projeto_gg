extends StaticBody2D
class_name PassagemLateral

@export var area_transicao_path: NodePath

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var colisao: CollisionShape2D = get_node_or_null("CollisionShape2D")

var aberta := false



func abrir(instantaneo: bool = false) -> void:
	if aberta:
		return

	aberta = true

	if colisao:
		colisao.set_deferred("disabled", true)

	var area_transicao := get_node_or_null(area_transicao_path)
	if area_transicao:
		area_transicao.monitoring = true

	if instantaneo:
		visible = false
		modulate.a = 0.0
		return

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): visible = false)
