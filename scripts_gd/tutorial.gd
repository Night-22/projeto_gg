extends Node2D

@onready var texto_tutorial = get_node("HUD_Tutorial/RichTextLabel")

var tween_tutorial: Tween


func _ready():
	texto_tutorial.modulate.a = 0.0


func mostrar_tutorial(texto: String) -> void:
	texto_tutorial.text = texto

	if tween_tutorial:
		tween_tutorial.kill()

	tween_tutorial = create_tween()
	tween_tutorial.tween_property(
		texto_tutorial,
		"modulate:a",
		1.0,
		0.3
	)


func esconder_tutorial() -> void:
	if tween_tutorial:
		tween_tutorial.kill()

	tween_tutorial = create_tween()
	tween_tutorial.tween_property(
		texto_tutorial,
		"modulate:a",
		0.0,
		0.3
	)


func _on_dash_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		mostrar_tutorial("Aperte o botão direito para usar o dash.")


func _on_dash_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esconder_tutorial()


func _on_planar_e_pulo_duplo_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		mostrar_tutorial("Pressione ESPAÇO no ar para ativar o pulo duplo e use novamente para planar.")


func _on_planar_e_pulo_duplo_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esconder_tutorial()


func _on_interagir_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		mostrar_tutorial("Pressione Q para interagir.")


func _on_interagir_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esconder_tutorial()


func _on_descer_plataforma_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		mostrar_tutorial("Aperte para baixo e pule para descer.")


func _on_descer_plataforma_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esconder_tutorial()


func _on_escada_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esconder_tutorial()


func _on_escada_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		mostrar_tutorial("Aperte para cima para subir na escada.")
