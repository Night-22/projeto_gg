extends CanvasLayer

var player = null
var bancada = null
var bloquear_reabertura = false

@onready var botao_salvar: Button = $Fundo/VBoxContainer/BotaoSalvar
@onready var botao_craft: Button = $Fundo/VBoxContainer/BotoesSecundarios/BotaoCraft
@onready var botao_equipar: Button = $Fundo/VBoxContainer/BotoesSecundarios/BotaoEquipar

# Artes dos botões da bancada
var textura_botao_salvar = preload("res://assets/menus/botao1.png")
var textura_botao_salvar_hover = preload("res://assets/menus/botao_hover.png")
var textura_botao_craft = preload("res://assets/menus/craftar.png")
var textura_botao_equipar = preload("res://assets/menus/inventario.png")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Bancada_menu")
	add_to_group("Menus")

	player = get_tree().get_first_node_in_group("Player")

	visible = false

	botao_salvar.pressed.connect(_on_botao_salvar_pressed)
	botao_craft.pressed.connect(_on_botao_craft_pressed)
	botao_equipar.pressed.connect(_on_botao_equipar_pressed)

	aplicar_estilos_visuais()


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


# Cria um StyleBoxTexture a partir de uma arte de botão, preservando bordas
# (texture_margin) e permitindo tingir a cor para simular hover/estado.
func criar_stylebox_botao(textura: Texture2D, margem: int = 5, cor: Color = Color(1, 1, 1, 1)) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.texture_margin_left = margem
	estilo.texture_margin_right = margem
	estilo.texture_margin_top = margem
	estilo.texture_margin_bottom = margem
	estilo.content_margin_left = 6
	estilo.content_margin_right = 6
	estilo.content_margin_top = 4
	estilo.content_margin_bottom = 4
	estilo.modulate_color = cor
	return estilo


func aplicar_estilos_visuais() -> void:
	# Botão Salvar: usa a arte com par normal/hover dedicado
	var salvar_normal = criar_stylebox_botao(textura_botao_salvar, 5)
	var salvar_hover = criar_stylebox_botao(textura_botao_salvar_hover, 5)

	botao_salvar.add_theme_stylebox_override("normal", salvar_normal)
	botao_salvar.add_theme_stylebox_override("hover", salvar_hover)
	botao_salvar.add_theme_stylebox_override("pressed", salvar_hover)
	botao_salvar.add_theme_stylebox_override("focus", salvar_hover)
	botao_salvar.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	botao_salvar.add_theme_constant_override("outline_size", 2)

	# Botões Craft e Equipar: sem arte de hover dedicada, então simulamos
	# o hover clareando a própria textura (modulate).
	aplicar_estilo_icone(botao_craft, textura_botao_craft)
	aplicar_estilo_icone(botao_equipar, textura_botao_equipar)


func aplicar_estilo_icone(button: Button, textura: Texture2D) -> void:
	var estilo_normal = criar_stylebox_botao(textura, 6)
	var estilo_hover = criar_stylebox_botao(textura, 6, Color(1.2, 1.2, 1.2, 1))

	button.add_theme_stylebox_override("normal", estilo_normal)
	button.add_theme_stylebox_override("hover", estilo_hover)
	button.add_theme_stylebox_override("pressed", estilo_hover)
	button.add_theme_stylebox_override("focus", estilo_hover)

	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 11)
