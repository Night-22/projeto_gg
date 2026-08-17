extends CanvasLayer

@onready var botao_slot_1: Button = $Fundo/VBoxContainer/Slot1
@onready var botao_slot_2: Button = $Fundo/VBoxContainer/Slot2
@onready var botao_slot_3: Button = $Fundo/VBoxContainer/Slot3


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Save_menu")
	add_to_group("Menus")

	visible = false

	botao_slot_1.pressed.connect(func(): salvar_no_slot(1))
	botao_slot_2.pressed.connect(func(): salvar_no_slot(2))
	botao_slot_3.pressed.connect(func(): salvar_no_slot(3))


func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return

	if event.is_action_pressed("interagir"):
		fechar_menu()
		get_viewport().set_input_as_handled()


func abrir_menu() -> void:
	visible = true
	get_tree().paused = true

	atualizar_slots()


func fechar_menu() -> void:
	visible = false
	get_tree().paused = false


func atualizar_slots() -> void:
	atualizar_slot(1, botao_slot_1)
	atualizar_slot(2, botao_slot_2)
	atualizar_slot(3, botao_slot_3)


func atualizar_slot(slot: int, botao: Button) -> void:
	if SaveManager.slot_existe(slot):
		var info = SaveManager.obter_info_slot(slot)
		var data_hora = info.get("data_hora", "")

		botao.text = "Slot %d - Salvo (%s)" % [slot, data_hora]
	else:
		botao.text = "Slot %d - Vazio" % slot


func salvar_no_slot(slot: int) -> void:
	var player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if SaveManager.salvar_jogo(slot, player):
		atualizar_slots()
