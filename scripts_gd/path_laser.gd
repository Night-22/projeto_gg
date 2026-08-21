extends PathFollow2D

@export var velocidade := 50.0
@export var suavidade := 8.0

var alvo := 0.0
var direcao := 1.0

@onready var caminho: Path2D = get_parent()

func _ready() -> void:
	alvo = progress

func _process(delta: float) -> void:
	if caminho.curve == null:
		return

	var comprimento := caminho.curve.get_baked_length()

	if comprimento <= 0.0:
		return

	alvo += direcao * velocidade * delta

	if alvo >= comprimento:
		alvo = comprimento
		direcao = -1.0

	elif alvo <= 0.0:
		alvo = 0.0
		direcao = 1.0

	progress = lerp(progress, alvo, suavidade * delta)
