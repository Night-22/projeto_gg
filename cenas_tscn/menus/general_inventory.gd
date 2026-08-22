extends CanvasLayer

const SLOTS_MINIMOS_ITENS = 12

var player = null

var spell_names = {
	0: "WATER 1",
	1: "WATER 2",
	2: "WATER 3",
	3: "WATER 4",
	4: "FIRE 1",
	5: "FIRE 2",
	6: "FIRE 3",
	7: "FIRE 4",
	8: "LIGHTNING 1",
	9: "LIGHTNING 2",
	10: "LIGHTNING 3",
	11: "LIGHTNING 4",
	12: "PLANT 1",
	13: "PLANT 2",
	14: "PLANT 3",
	15: "PLANT 4"
}

@onready var grid_magias: GridContainer = $Fundo/VBoxContainer/MagiasEquipadas/GridMagias
@onready var grid_itens: GridContainer = $Fundo/VBoxContainer/Itens/GridItens

var medalhao_elementos = {
	"medalhao_fogo": 0,
	"medalhao_agua": 1,
	"medalhao_raio": 2,
	"medalhao_planta": 3
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Inventario_geral")
	add_to_group("Menus")

	player = get_tree().get_first_node_in_group("Player")

	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventario"):
		if visible:
			fechar_menu()
		else:
			abrir_menu()

		get_viewport().set_input_as_handled()
		return

	if !visible:
		return

	if event.is_action_pressed("interagir"):
		fechar_menu()
		get_viewport().set_input_as_handled()


func abrir_menu() -> void:
	if player == null or !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if player.spell_in_use:
		return

	for menu in get_tree().get_nodes_in_group("Menus"):
		if menu != self and is_instance_valid(menu) and menu.visible:
			return

	atualizar_magias()
	atualizar_itens()

	visible = true
	get_tree().paused = true


func fechar_menu() -> void:
	visible = false
	get_tree().paused = false


func atualizar_magias() -> void:
	if grid_magias == null:
		return

	for child in grid_magias.get_children():
		child.queue_free()

	if player == null:
		return

	for spell_id in player.equipped_spells:
		var caixa := Button.new()

		caixa.text = get_spell_name(spell_id)
		caixa.custom_minimum_size = Vector2(72, 40)
		caixa.add_theme_font_size_override("font_size", 8)
		caixa.disabled = true
		caixa.focus_mode = Control.FOCUS_NONE

		grid_magias.add_child(caixa)


func atualizar_itens() -> void:
	if grid_itens == null:
		return

	for child in grid_itens.get_children():
		child.queue_free()

	if player == null:
		return

	var total_slots = max(SLOTS_MINIMOS_ITENS, player.inventario_itens.size())

	for i in range(total_slots):
		var caixa := Button.new()

		caixa.custom_minimum_size = Vector2(50, 32)
		caixa.add_theme_font_size_override("font_size", 7)
		caixa.disabled = true
		caixa.focus_mode = Control.FOCUS_NONE

		if i < player.inventario_itens.size():
			var item = player.inventario_itens[i]
			var texto = "%s x%d" % [item.get("nome", "?"), item.get("quantidade", 1)]
			var id = item.get("id", "")

			if medalhao_elementos.has(id):
				var elemento = medalhao_elementos[id]

				caixa.disabled = false

				if player.obter_medalhao_ativo() == elemento:
					caixa.text = texto + "\n[EQUIPADO]"
					caixa.modulate = Color(1.0, 0.85, 0.3)
				else:
					caixa.text = texto

				caixa.pressed.connect(_on_medalhao_pressed.bind(elemento))
			else:
				caixa.text = texto
		else:
			caixa.text = ""

		grid_itens.add_child(caixa)


func _on_medalhao_pressed(elemento: int) -> void:
	if player == null:
		return

	player.alternar_medalhao(elemento)
	atualizar_itens()


func get_spell_name(spell_id) -> String:
	if spell_id == null:
		return "VAZIO"

	if spell_names.has(spell_id):
		return spell_names[spell_id]

	return "?"
