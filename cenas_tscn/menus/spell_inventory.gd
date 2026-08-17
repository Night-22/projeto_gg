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

@onready var inventory_grid: GridContainer = $Background/MarginContainer/VBoxContainer/InventoryGrid
@onready var slot_1: Button = $Background/MarginContainer/VBoxContainer/EquippedGrid/Slot1
@onready var slot_2: Button = $Background/MarginContainer/VBoxContainer/EquippedGrid/Slot2
@onready var slot_3: Button = $Background/MarginContainer/VBoxContainer/EquippedGrid/Slot3
@onready var slot_4: Button = $Background/MarginContainer/VBoxContainer/EquippedGrid/Slot4


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
		button.custom_minimum_size = Vector2(140, 55)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			func(id = spell_id):
				selecionar_magia(id)
		)

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


func get_spell_name(spell_id: int) -> String:
	if spell_names.has(spell_id):
		return spell_names[spell_id]

	return "UNKNOWN"
