extends PathFollow2D

@export var velocidade := 150.0

var indo = true

func _process(delta):
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.receber_dano(10, global_position.x)
