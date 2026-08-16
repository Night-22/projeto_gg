extends CanvasLayer

var player

@onready var health_bar: ProgressBar = $Interface/HealthBar
@onready var mana_bar: ProgressBar = $Interface/ManaBar

@onready var spell_1_name: Label = $Interface/SpellBar/SpellSlot1/Label
@onready var spell_2_name: Label = $Interface/SpellBar/SpellSlot2/Label
@onready var spell_3_name: Label = $Interface/SpellBar/SpellSlot3/Label
@onready var spell_4_name: Label = $Interface/SpellBar/SpellSlot4/Label

@onready var spell_1_cooldown: ColorRect = $Interface/SpellBar/SpellSlot1/CooldownOverlay
@onready var spell_2_cooldown: ColorRect = $Interface/SpellBar/SpellSlot2/CooldownOverlay
@onready var spell_3_cooldown: ColorRect = $Interface/SpellBar/SpellSlot3/CooldownOverlay
@onready var spell_4_cooldown: ColorRect = $Interface/SpellBar/SpellSlot4/CooldownOverlay

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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	player = get_tree().get_first_node_in_group("Player")

	update_spell_names()
	update_selected_spell()
	update_cooldowns()


func _process(_delta: float) -> void:
	atualizar_visibilidade()

	if player == null:
		player = get_tree().get_first_node_in_group("Player")

		if player == null:
			return

	update_bars()
	update_spell_names()
	update_selected_spell()
	update_cooldowns()


func atualizar_visibilidade() -> void:
	var menu_aberto = false

	for menu in get_tree().get_nodes_in_group("Menus"):
		if is_instance_valid(menu) and menu.visible:
			menu_aberto = true
			break

	visible = !menu_aberto


func update_bars() -> void:
	health_bar.max_value = player.max_life
	health_bar.value = player.Life

	mana_bar.max_value = player.max_mana
	mana_bar.value = player.Mana


func update_spell_names() -> void:
	if player == null:
		return

	if player.equipped_spells.size() < 4:
		return

	spell_1_name.text = get_spell_name(player.equipped_spells[0])
	spell_2_name.text = get_spell_name(player.equipped_spells[1])
	spell_3_name.text = get_spell_name(player.equipped_spells[2])
	spell_4_name.text = get_spell_name(player.equipped_spells[3])


func get_spell_name(spell_id) -> String:
	if spell_id == null:
		return "EMPTY"

	if spell_names.has(spell_id):
		return spell_names[spell_id]

	return "UNKNOWN"


func update_selected_spell() -> void:
	if player == null:
		return

	spell_1_name.modulate.a = 0.5
	spell_2_name.modulate.a = 0.5
	spell_3_name.modulate.a = 0.5
	spell_4_name.modulate.a = 0.5

	match player.selected_spell:
		0:
			spell_1_name.modulate.a = 1.0
		1:
			spell_2_name.modulate.a = 1.0
		2:
			spell_3_name.modulate.a = 1.0
		3:
			spell_4_name.modulate.a = 1.0


func update_cooldowns() -> void:
	update_spell_cooldown(0, spell_1_cooldown)
	update_spell_cooldown(1, spell_2_cooldown)
	update_spell_cooldown(2, spell_3_cooldown)
	update_spell_cooldown(3, spell_4_cooldown)


func update_spell_cooldown(index: int, overlay: ColorRect) -> void:
	if player == null:
		return

	if index >= player.active_spells.size():
		overlay.visible = false
		return

	var spell = player.active_spells[index]

	if spell == null:
		overlay.visible = false
		return

	if !spell.has_method("get_cooldown_percent"):
		overlay.visible = false
		return

	var percent = spell.get_cooldown_percent()

	if percent <= 0:
		overlay.visible = false
		return

	overlay.visible = true

	var parent = overlay.get_parent()

	overlay.size.y = parent.size.y * percent
	overlay.position.y = parent.size.y - overlay.size.y
