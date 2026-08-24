extends CanvasLayer

var player = null
var bancada = null
var selected_spell = -1
var bloquear_reabertura = false

var spell_names = {
	0: "ÁGUA I",
	1: "ÁGUA II",
	2: "ÁGUA III",
	3: "ÁGUA IV",
	4: "FOGO I",
	5: "FOGO II",
	6: "FOGO III",
	7: "FOGO IV",
	8: "RAIO I",
	9: "RAIO II",
	10: "RAIO III",
	11: "RAIO IV",
	12: "PLANTA I",
	13: "PLANTA II",
	14: "PLANTA III",
	15: "PLANTA IV"
}

var elemento_nomes = {
	0: "Fogo",
	1: "Água",
	2: "Raio",
	3: "Planta"
}

var elemento_texturas = {
	0: preload("res://placeholder/fogo.png"),
	1: preload("res://placeholder/agua.png"),
	2: preload("res://placeholder/raio.png"),
	3: preload("res://placeholder/planta.png")
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

var textura_botao_craftar = preload("res://assets/menus/botao_craftar_magia.png")

@onready var almas_agua_label: Label = $AlmasContainer/Agua/Quantidade
@onready var almas_fogo_label: Label = $AlmasContainer/Fogo/Quantidade
@onready var almas_raio_label: Label = $AlmasContainer/Raio/Quantidade
@onready var almas_planta_label: Label = $AlmasContainer/Planta/Quantidade

@onready var grid_magias: GridContainer = $PainelMagias/Margem/GridContainer/GridMagias
@onready var elemento_label: Label = $PainelDetalhes/Conteúdo/Elemento
@onready var icone_rect: TextureRect = $PainelDetalhes/Conteúdo/Icone
@onready var nome_label: Label = $PainelDetalhes/Conteúdo/Nome
@onready var custo_label: Label = $PainelDetalhes/Conteúdo/Custo
@onready var quantidade_label: Label = $PainelDetalhes/Conteúdo/Quantidade
@onready var botao_craftar: Button = $"PainelDetalhes/BotaoCraftar"
@onready var fonte = preload("uid://bxls3mwagmlq3")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Craft_menu")

	player = get_tree().get_first_node_in_group("Player")

	visible = false

	aplicar_estilo_botao_craftar()

	criar_grid_magias()
	atualizar_almas()
	atualizar_painel_detalhes()

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

	if bancada == null or !is_instance_valid(bancada):
		return

	if player.spell_in_use:
		return

	selected_spell = -1

	criar_grid_magias()
	atualizar_almas()
	atualizar_painel_detalhes()

	visible = true
	get_tree().paused = true

func fechar_menu() -> void:
	if !visible:
		return

	visible = false
	selected_spell = -1
	bloquear_reabertura = true
	get_tree().paused = false

	call_deferred("_liberar_bloqueio_reabertura")

func _liberar_bloqueio_reabertura() -> void:
	bloquear_reabertura = false

func esta_bloqueado_para_reabrir() -> bool:
	return bloquear_reabertura

func definir_bancada(nova_bancada) -> void:
	if nova_bancada == null:
		return

	bancada = nova_bancada

func remover_bancada(bancada_saida) -> void:
	if bancada != bancada_saida:
		return

	bancada = null

	if visible:
		fechar_menu()

func criar_grid_magias() -> void:
	if grid_magias == null:
		return

	if player == null:
		return

	for child in grid_magias.get_children():
		child.queue_free()

	for spell_id in player.all_spells:
		if player.magia_desbloqueada(spell_id):
			continue

		var button := Button.new()

		button.text = get_spell_name(spell_id)
		button.custom_minimum_size = Vector2(71, 14)
		button.add_theme_font_size_override("font_size", 7)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			func(id = spell_id):
				selecionar_magia(id)
		)

		var elemento_da_magia = player.obter_elemento_da_magia(spell_id)
		aplicar_estilo_botao_magia(button, elemento_da_magia)

		grid_magias.add_child(button)

func criar_stylebox_botao(textura: Texture2D, margem: int = 5, cor: Color = Color(1, 1, 1, 1)) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	estilo.texture_margin_left = margem
	estilo.texture_margin_right = margem
	estilo.texture_margin_top = margem
	estilo.texture_margin_bottom = margem
	estilo.content_margin_left = 6
	estilo.content_margin_right = 6
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

func aplicar_estilo_botao_craftar() -> void:
	var estilo_normal = criar_stylebox_botao(textura_botao_craftar, 4)
	var estilo_hover = criar_stylebox_botao(textura_botao_craftar, 4, Color(1.2, 1.2, 1.2, 1))
	var estilo_disabled = criar_stylebox_botao(textura_botao_craftar, 4, Color(0.45, 0.45, 0.45, 1))

	botao_craftar.add_theme_stylebox_override("normal", estilo_normal)
	botao_craftar.add_theme_stylebox_override("hover", estilo_hover)
	botao_craftar.add_theme_stylebox_override("pressed", estilo_hover)
	botao_craftar.add_theme_stylebox_override("disabled", estilo_disabled)

	botao_craftar.add_theme_color_override("font_color", Color(1, 1, 1))
	botao_craftar.add_theme_color_override("font_disabled_color", Color(0.85, 0.85, 0.85))
	botao_craftar.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	botao_craftar.add_theme_constant_override("outline_size", 2)

func selecionar_magia(spell_id: int) -> void:
	selected_spell = spell_id
	atualizar_painel_detalhes()

func atualizar_almas() -> void:
	if player == null:
		return

	almas_agua_label.text = str(player.almas_agua)
	almas_fogo_label.text = str(player.almas_fogo)
	almas_raio_label.text = str(player.almas_raio)
	almas_planta_label.text = str(player.almas_planta)

func atualizar_painel_detalhes() -> void:
	if selected_spell == -1:
		nome_label.text = "Selecione uma magia"
		icone_rect.texture = null
		elemento_label.text = ""
		custo_label.text = ""
		quantidade_label.text = ""
		botao_craftar.disabled = true
		return

	if player == null:
		return

	var elemento = player.obter_elemento_da_magia(selected_spell)
	var custo = player.obter_custo_da_magia(selected_spell)
	var almas_disponiveis = player.obter_almas_do_elemento(elemento)

	nome_label.text = get_spell_name(selected_spell)
	icone_rect.texture = elemento_texturas.get(elemento)
	elemento_label.text = "Elemento: " + get_elemento_nome(elemento)
	custo_label.text = "Custo: %d almas" % custo
	quantidade_label.text = "Você tem: %d almas" % almas_disponiveis

	botao_craftar.disabled = !player.pode_craftar_magia(selected_spell)

func _on_botao_craftar_pressed() -> void:
	if selected_spell == -1:
		return

	if player == null:
		return

	if !player.craftar_magia(selected_spell):
		return

	selected_spell = -1

	criar_grid_magias()
	atualizar_almas()
	atualizar_painel_detalhes()

func get_spell_name(spell_id: int) -> String:
	if spell_names.has(spell_id):
		return spell_names[spell_id]

	return "DESCONHECIDA"

func get_elemento_nome(elemento: int) -> String:
	if elemento_nomes.has(elemento):
		return elemento_nomes[elemento]

	return "?"
