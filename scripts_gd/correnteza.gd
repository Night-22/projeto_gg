extends Bolha
class_name Correnteza

@export var velocidade_correnteza := -250.0

var jogador = null


func _physics_process(_delta):
	if jogador == null:
		return

	# Só aplica a correnteza quando o jogador NÃO estiver subindo por causa de um pulo.
	# Assim o pulo continua funcionando normalmente.
	if jogador.velocity.y >= 0:
		jogador.velocity.y = velocidade_correnteza


func _on_body_entered(body):
	if body.is_in_group("Player"):
		jogador = body


func _on_body_exited(body):
	if body == jogador:
		jogador = null
