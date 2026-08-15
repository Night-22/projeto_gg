extends Area2D

var speed = 500.0
var damage = 2
var direction = Vector2.RIGHT


func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
		
	if body.has_method("receber_dano"):
		body.receber_dano(damage, global_position.x)
