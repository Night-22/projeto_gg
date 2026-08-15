extends Area2D
class_name TeiaProjetil

var velocidade := 480.0
var dano := 2
var chao_y := 600.0

var _atingiu := false


func _physics_process(delta: float) -> void:
	position.y += velocidade * delta

	if global_position.y >= chao_y:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _atingiu:
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		_atingiu = true
		body.receber_dano(dano, global_position.x)
		queue_free()
