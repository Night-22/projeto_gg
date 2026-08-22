extends CanvasLayer

@onready var painel: Control = $Painel
@onready var botao_continuar: Button = $Painel/VBoxContainer/BotaoContinuar
@onready var botao_opcoes: Button = $Painel/VBoxContainer/BotaoOpcoes
@onready var botao_menu_principal: Button = $Painel/VBoxContainer/BotaoMenuPrincipal
@onready var opcoes_menu = $OpcoesMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Menus")

	visible = false
	painel.visible = false

	botao_continuar.pressed.connect(continuar)
	botao_opcoes.pressed.connect(_abrir_opcoes)
	botao_menu_principal.pressed.connect(_voltar_ao_menu_principal)

	opcoes_menu.voltar_pressionado.connect(func(): painel.visible = true)


func _unhandled_input(event: InputEvent) -> void:
	if !event.is_action_pressed("pausar"):
		return

	if opcoes_menu.visible:
		return

	if visible:
		continuar()
	else:
		abrir_menu()

	get_viewport().set_input_as_handled()


func abrir_menu() -> void:
	for menu in get_tree().get_nodes_in_group("Menus"):
		if menu != self and is_instance_valid(menu) and menu.visible:
			return

	visible = true
	painel.visible = true
	get_tree().paused = true


func continuar() -> void:
	visible = false
	painel.visible = false
	get_tree().paused = false


func _abrir_opcoes() -> void:
	painel.visible = false
	opcoes_menu.abrir()


func _voltar_ao_menu_principal() -> void:
	continuar()
	get_tree().change_scene_to_file("res://cenas_tscn/menus/main_menu.tscn")
