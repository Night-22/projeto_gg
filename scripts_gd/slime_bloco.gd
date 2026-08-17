extends Area2D

var jogador = null

@export var jump_velocity = 500

var escala_original = Vector2.ONE


func _ready():
	escala_original = scale


func _on_body_entered(body):
	if body.is_in_group("Player"):
		jogador = body
		jogador.slime_jump_velocity = jump_velocity
		jogador.jump()

		animar_slime()


func animar_slime():
	var tween = create_tween()

	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.08)
	tween.tween_property(self, "scale", Vector2(0.8, 1.3), 0.08)
	tween.tween_property(self, "scale", Vector2(1.1, 0.9), 0.07)
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 0.07)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _on_body_exited(body):
	if body == jogador:
		jogador = null
