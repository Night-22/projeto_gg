extends Area2D

@export var velocidade := 200.0

var direcao := Vector2.RIGHT

func _physics_process(delta):
	global_position += direcao * velocidade * delta
