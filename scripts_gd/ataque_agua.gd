extends Area2D

var speed = 200.0
var damage = 2
var direction = Vector2.RIGHT

@onready var anim: AnimatedSprite2D = $anim


func _process(delta: float) -> void:
	global_position += direction * speed * delta
	anim.play("sla")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigo"):
		return

	if body.is_in_group("ProjetilJogador") or body.is_in_group("ProjetilInimigo"):
		return

	if body.is_in_group("Player"):
		if body.has_method("receber_dano"):
			body.receber_dano(damage, global_position.x)
		return

	# Colidiu com algo que não toma dano (parede, chão, etc) -> destrói o projétil
	queue_free()
