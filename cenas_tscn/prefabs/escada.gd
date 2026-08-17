extends Area2D

@onready var area_subir: Area2D = $AreaSubir

var jogadores = []


func _ready() -> void:
	add_to_group("Escada")


func _on_area_subir_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body not in jogadores:
		jogadores.append(body)

	if body.has_method("entrar_na_escada"):
		body.entrar_na_escada(self)


func _on_area_subir_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	jogadores.erase(body)

	if body.has_method("sair_da_escada"):
		body.sair_da_escada(self)


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
	
