extends Area2D

@onready var area_pendurar: Area2D = $AreaPendurar

var jogadores = []


func _ready() -> void:
	add_to_group("Cipo")


func _on_area_pendurar_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body not in jogadores:
		jogadores.append(body)

	if body.has_method("entrar_no_cipo"):
		body.entrar_no_cipo(self)


func _on_area_pendurar_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	jogadores.erase(body)

	if body.has_method("sair_do_cipo"):
		body.sair_do_cipo(self)


func jogador_dentro() -> bool:
	for jogador in jogadores:
		if is_instance_valid(jogador):
			return true

	return false


func obter_jogador() -> Node2D:
	for jogador in jogadores:
		if is_instance_valid(jogador):
			return jogador

	return null
