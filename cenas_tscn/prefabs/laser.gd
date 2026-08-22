extends PathFollow2D

@export var velocidade := 50.0
@export var posicao_inicial := 0.0

var indo := true

func _ready() -> void:
	progress = posicao_inicial

func _process(delta: float) -> void:
	var caminho = get_parent().curve

	if caminho == null:
		return

	var comprimento = caminho.get_baked_length()

	if indo:
		progress += velocidade * delta

		if progress >= comprimento:
			progress = comprimento
			indo = false
	else:
		progress -= velocidade * delta

		if progress <= 0:
			progress = 0
			indo = true
