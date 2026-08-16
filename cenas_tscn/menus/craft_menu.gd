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
@onready var botao_craftar: Button = $"PainelDetalhes/Conteúdo/BotaoCraftar"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Craft_menu")

	player = get_tree().get_first_node_in_group("Player")

	visible = false

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
		button.custom_minimum_size = Vector2(140, 50)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			func(id = spell_id):
				selecionar_magia(id)
		)

		grid_magias.add_child(button)

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
