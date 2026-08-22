extends CanvasLayer

@onready var slider_master: HSlider = $Fundo/VBoxContainer/SliderMaster
@onready var slider_musica: HSlider = $Fundo/VBoxContainer/SliderMusica
@onready var slider_sfx: HSlider = $Fundo/VBoxContainer/SliderSfx
@onready var botao_mudo: CheckButton = $Fundo/VBoxContainer/BotaoMudo
@onready var botao_voltar: Button = $Fundo/VBoxContainer/BotaoVoltar

signal voltar_pressionado


func _ready() -> void:
	visible = false

	_atualizar_controles()

	slider_master.value_changed.connect(Opcoes.definir_volume_master)
	slider_musica.value_changed.connect(Opcoes.definir_volume_musica)
	slider_sfx.value_changed.connect(Opcoes.definir_volume_sfx)
	botao_mudo.toggled.connect(Opcoes.alternar_mudo)

	botao_voltar.pressed.connect(fechar)


func abrir() -> void:
	visible = true
	_atualizar_controles()


func fechar() -> void:
	visible = false
	voltar_pressionado.emit()


func _atualizar_controles() -> void:
	slider_master.value = Opcoes.volume_master
	slider_musica.value = Opcoes.volume_musica
	slider_sfx.value = Opcoes.volume_sfx
	botao_mudo.button_pressed = Opcoes.mudo
