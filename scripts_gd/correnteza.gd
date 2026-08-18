extends Bolha
class_name Correnteza

@export var velocidade_subida = -250.0

var jogador = null


func _physics_process(_delta):
	if jogador:
		jogador.velocity.y = velocidade_subida


func _on_body_entered(body):
	if body.is_in_group("Player"):
		jogador = body


func _on_body_exited(body):
	if body == jogador:
		jogador = null
