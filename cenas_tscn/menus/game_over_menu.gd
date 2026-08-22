extends CanvasLayer

signal escolha_feita(tipo: String)

@onready var escuridao: ColorRect = $Escuridao
@onready var painel: Control = $Painel
@onready var botao_checkpoint: Button = $Painel/VBoxContainer/BotaoCheckpoint
@onready var botao_menu: Button = $Painel/VBoxContainer/BotaoMenu

var tween_fade: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("Menus")

	visible = false
	painel.visible = false
	escuridao.modulate.a = 0.0

	botao_checkpoint.pressed.connect(func(): _escolher("checkpoint"))
	botao_menu.pressed.connect(func(): _escolher("menu"))


func iniciar_morte() -> void:
	visible = true
	painel.visible = false
	escuridao.modulate.a = 0.0

	if tween_fade:
		tween_fade.kill()

	tween_fade = create_tween()
	tween_fade.tween_property(escuridao, "modulate:a", 1.0, 0.6)


func mostrar_menu() -> void:
	if tween_fade:
		tween_fade.kill()

	tween_fade = create_tween()
	tween_fade.tween_property(escuridao, "modulate:a", 1.0, 0.15)
	tween_fade.finished.connect(func():
		painel.visible = true
		get_tree().paused = true
	)


func esconder() -> void:
	visible = false
	painel.visible = false
	escuridao.modulate.a = 0.0
	get_tree().paused = false


func _escolher(tipo: String) -> void:
	esconder()
	escolha_feita.emit(tipo)
