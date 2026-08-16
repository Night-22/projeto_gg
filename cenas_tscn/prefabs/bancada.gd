extends Area2D

var jogadores = []

func _ready() -> void:
	add_to_group("Bancada")


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body not in jogadores:
		jogadores.append(body)

	if body.has_method("entrar_na_bancada"):
		body.entrar_na_bancada(self)

	var menu = get_tree().get_first_node_in_group("Craft_menu")

	if menu != null and menu.has_method("definir_bancada"):
		menu.definir_bancada(self)

func _on_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	jogadores.erase(body)

	if body.has_method("sair_da_bancada"):
		body.sair_da_bancada(self)

	var menu = get_tree().get_first_node_in_group("Craft_menu")

	if menu != null and menu.has_method("remover_bancada"):
		menu.remover_bancada(self)

func interagir() -> void:
	if !jogador_dentro():
		return

	var menu = get_tree().get_first_node_in_group("Craft_menu")

	if menu == null:
		return

	if menu.has_method("esta_bloqueado_para_reabrir"):
		if menu.esta_bloqueado_para_reabrir():
			return

	if menu.visible:
		return

	if menu.has_method("abrir_menu"):
		menu.abrir_menu()

func jogador_dentro() -> bool:
	for jogador in jogadores:
		if is_instance_valid(jogador):
			return true

	return false
