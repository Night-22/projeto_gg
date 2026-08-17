extends AnimatableBody2D

@export_enum("Cima", "Baixo", "Esquerda", "Direita") var direcao: String = "Cima"
@export var distancia: float = 100.0
@export var velocidade: float = 200.0

var posicao_inicial: Vector2
var tempo: float = 0.0
var movimento := Vector2.ZERO


func _ready() -> void:
	posicao_inicial = global_position

	match direcao:
		"Cima":
			movimento = Vector2.UP
		"Baixo":
			movimento = Vector2.DOWN
		"Esquerda":
			movimento = Vector2.LEFT
		"Direita":
			movimento = Vector2.RIGHT


func _physics_process(delta: float) -> void:
	tempo += delta * velocidade / distancia

	var deslocamento := (sin(tempo) + 1.0) / 2.0

	global_position = posicao_inicial + movimento * distancia * deslocamento
