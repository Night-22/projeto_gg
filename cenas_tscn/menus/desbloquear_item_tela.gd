extends CanvasLayer

signal fechou_tela

const TEMPO_FADE_LINHA := 0.5
const INTERVALO_ENTRE_LINHAS := 0.5

@onready var icone_rect: TextureRect = $Fundo/Centro/Icone
@onready var titulo_label: Label = $Fundo/Centro/Titulo
@onready var linhas_container: VBoxContainer = $Fundo/Centro/LinhasDescricao
@onready var prompt_label: Label = $Fundo/Centro/Prompt

var pronto_para_fechar := false


func _ready() -> void:
	add_to_group("Menus")
	visible = false


func _input(event: InputEvent) -> void:
	if !visible or !pronto_para_fechar:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fechar_tela()
		get_viewport().set_input_as_handled()


func mostrar_item(titulo: String, descricao: String, icone: Texture2D = null) -> void:
	titulo_label.text = titulo

	for child in linhas_container.get_children():
		linhas_container.remove_child(child)
		child.queue_free()

	for linha in descricao.split("\n"):
		if linha.strip_edges() == "":
			continue

		var label := Label.new()
		label.text = linha
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		label.modulate.a = 0.0
		linhas_container.add_child(label)

	icone_rect.texture = icone
	icone_rect.visible = icone != null

	prompt_label.modulate.a = 0.0
	pronto_para_fechar = false

	visible = true
	get_tree().paused = true

	await animar_linhas()


func animar_linhas() -> void:
	for label in linhas_container.get_children():
		var tween := create_tween()
		tween.tween_property(label, "modulate:a", 1.0, TEMPO_FADE_LINHA)
		await tween.finished
		await get_tree().create_timer(INTERVALO_ENTRE_LINHAS).timeout

	var tween_prompt := create_tween()
	tween_prompt.tween_property(prompt_label, "modulate:a", 1.0, TEMPO_FADE_LINHA)
	await tween_prompt.finished

	pronto_para_fechar = true


func fechar_tela() -> void:
	visible = false
	get_tree().paused = false
	pronto_para_fechar = false
	fechou_tela.emit()
