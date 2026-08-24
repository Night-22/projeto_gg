extends CanvasLayer

var player = null
var selected_spell = -1
var selected_slot = -1

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


var elemento_botao_normal = {
	0: preload("res://assets/menus/botao_fogo1.png"),
	1: preload("res://assets/menus/botao_agua1.png"),
	2: preload("res://assets/menus/botao_raio1.png"),
	3: preload("res://assets/menus/botao_planta1.png")
}

var elemento_botao_hover = {
	0: preload("res://assets/menus/botao_fogo_hover.png"),
	1: preload("res://assets/menus/botao_agua_hover.png"),
	2: preload("res://assets/menus/botao_raio_hover.png"),
	3: preload("res://assets/menus/botao_planta2.png")
}

@onready var inventory_grid: GridContainer = $InventoryGrid
@onready var slot_1: Button = $EquippedGrid/Slot1
@onready var slot_2: Button = $EquippedGrid/Slot2
@onready var slot_3: Button = $EquippedGrid/Slot3
@onready var slot_4: Button = $EquippedGrid/Slot4


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Menus")
	add_to_group("Inventario_equipar")

	player = get_tree().get_first_node_in_group("Player")

	visible = false

	slot_1.pressed.connect(func(): selecionar_slot(0))
	slot_2.pressed.connect(func(): selecionar_slot(1))
	slot_3.pressed.connect(func(): selecionar_slot(2))
	slot_4.pressed.connect(func(): selecionar_slot(3))

	criar_inventario()
	atualizar_slots()


func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return

	if event.is_action_pressed("interagir"):
		fechar_menu()
		get_viewport().set_input_as_handled()


func abrir_menu() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if player.spell_in_use:
		return

	criar_inventario()

	selected_spell = -1
	selected_slot = -1

	visible = true

	atualizar_slots()

	get_tree().paused = true


func fechar_menu() -> void:
	visible = false

	selected_spell = -1
	selected_slot = -1

	get_tree().paused = false


func criar_inventario() -> void:
	if inventory_grid == null:
		return

	for child in inventory_grid.get_children():
		child.queue_free()

	if player == null:
		return

	for spell_id in player.spell_inventory:
		var button = Button.new()

		button.text = get_spell_name(spell_id)
		button.custom_minimum_size = Vector2(39, 23)
		button.add_theme_font_size_override("font_size", 6)
		button.clip_text = true
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			func(id = spell_id):
				selecionar_magia(id)
		)

		aplicar_estilo_botao_magia(button, player.obter_elemento_da_magia(spell_id))

		inventory_grid.add_child(button)


func atualizar_slots() -> void:
	if player == null:
		return

	if player.equipped_spells.size() < 4:
		return

	slot_1.text = get_spell_name(player.equipped_spells[0])
	slot_2.text = get_spell_name(player.equipped_spells[1])
	slot_3.text = get_spell_name(player.equipped_spells[2])
	slot_4.text = get_spell_name(player.equipped_spells[3])

	aplicar_estilo_botao_magia(slot_1, player.obter_elemento_da_magia(player.equipped_spells[0]))
	aplicar_estilo_botao_magia(slot_2, player.obter_elemento_da_magia(player.equipped_spells[1]))
	aplicar_estilo_botao_magia(slot_3, player.obter_elemento_da_magia(player.equipped_spells[2]))
	aplicar_estilo_botao_magia(slot_4, player.obter_elemento_da_magia(player.equipped_spells[3]))

	slot_1.modulate = Color.WHITE
	slot_2.modulate = Color.WHITE
	slot_3.modulate = Color.WHITE
	slot_4.modulate = Color.WHITE

	if selected_slot == 0:
		slot_1.modulate = Color(1.0, 0.8, 0.3)

	if selected_slot == 1:
		slot_2.modulate = Color(1.0, 0.8, 0.3)

	if selected_slot == 2:
		slot_3.modulate = Color(1.0, 0.8, 0.3)

	if selected_slot == 3:
		slot_4.modulate = Color(1.0, 0.8, 0.3)


func selecionar_magia(spell_id: int) -> void:
	selected_spell = spell_id

	if selected_slot != -1:
		equipar_magia()


func selecionar_slot(slot: int) -> void:
	selected_slot = slot

	if selected_spell != -1:
		equipar_magia()

	atualizar_slots()


func equipar_magia() -> void:
	if selected_spell == -1:
		return

	if selected_slot == -1:
		return

	if player.spell_in_use:
		return

	player.equip_spell(selected_slot, selected_spell)

	selected_spell = -1
	selected_slot = -1

	criar_inventario()
	atualizar_slots()


func criar_stylebox_botao(textura: Texture2D, margem: int = 3, cor: Color = Color(1, 1, 1, 1)) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.texture_margin_left = margem
	estilo.texture_margin_right = margem
	estilo.texture_margin_top = margem
	estilo.texture_margin_bottom = margem
	estilo.content_margin_left = 4
	estilo.content_margin_right = 4
	estilo.content_margin_top = 2
	estilo.content_margin_bottom = 2
	estilo.modulate_color = cor
	return estilo


func aplicar_estilo_botao_magia(button: Button, elemento: int) -> void:
	var textura_normal = elemento_botao_normal.get(elemento)

	if textura_normal == null:
		return

	var textura_hover = elemento_botao_hover.get(elemento, textura_normal)

	var estilo_normal = criar_stylebox_botao(textura_normal, 3)
	var estilo_hover = criar_stylebox_botao(textura_hover, 3)

	button.add_theme_stylebox_override("normal", estilo_normal)
	button.add_theme_stylebox_override("hover", estilo_hover)
	button.add_theme_stylebox_override("pressed", estilo_hover)
	button.add_theme_stylebox_override("focus", estilo_hover)

	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	button.add_theme_constant_override("outline_size", 2)


func get_spell_name(spell_id: int) -> String:
	if spell_names.has(spell_id):
		return spell_names[spell_id]

	return "UNKNOWN"
