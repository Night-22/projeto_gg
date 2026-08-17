extends CanvasLayer

var player = null
var bancada = null
var bloquear_reabertura = false

@onready var botao_salvar: Button = $Fundo/VBoxContainer/BotaoSalvar
@onready var botao_craft: Button = $Fundo/VBoxContainer/BotaoCraft
@onready var botao_equipar: Button = $Fundo/VBoxContainer/BotaoEquipar


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Bancada_menu")
	add_to_group("Menus")

	player = get_tree().get_first_node_in_group("Player")

	visible = false

	botao_salvar.pressed.connect(_on_botao_salvar_pressed)
	botao_craft.pressed.connect(_on_botao_craft_pressed)
	botao_equipar.pressed.connect(_on_botao_equipar_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return

	if event.is_action_pressed("interagir"):
		fechar_menu()
		get_viewport().set_input_as_handled()


func abrir_menu(nova_bancada = null) -> void:
	if bloquear_reabertura:
		return

	if player == null or !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if nova_bancada != null:
		bancada = nova_bancada

	if player.spell_in_use:
		return

	visible = true
	get_tree().paused = true


func fechar_menu() -> void:
	if !visible:
		return

	visible = false
	bloquear_reabertura = true
	get_tree().paused = false

	call_deferred("_liberar_bloqueio_reabertura")


func _liberar_bloqueio_reabertura() -> void:
	bloquear_reabertura = false


func esta_bloqueado_para_reabrir() -> bool:
	return bloquear_reabertura


# Esconde o hub (sem despausar) para abrir um dos submenus por cima.
func esconder_para_submenu() -> void:
	visible = false


func _on_botao_salvar_pressed() -> void:
	esconder_para_submenu()

	var menu = get_tree().get_first_node_in_group("Save_menu")

	if menu != null and menu.has_method("abrir_menu"):
		menu.abrir_menu()


func _on_botao_craft_pressed() -> void:
	esconder_para_submenu()

	var menu = get_tree().get_first_node_in_group("Craft_menu")

	if menu != null and menu.has_method("abrir_menu"):
		menu.abrir_menu(bancada)


func _on_botao_equipar_pressed() -> void:
	esconder_para_submenu()

	var menu = get_tree().get_first_node_in_group("Inventario_equipar")

	if menu != null and menu.has_method("abrir_menu"):
		menu.abrir_menu()
