extends CanvasLayer

const MODO_NOVO_JOGO := 0
const MODO_CONTINUAR := 1

@onready var titulo: Label = $Fundo/VBoxContainer/Titulo
@onready var botao_slot_1: Button = $Fundo/VBoxContainer/Slot1
@onready var botao_slot_2: Button = $Fundo/VBoxContainer/Slot2
@onready var botao_slot_3: Button = $Fundo/VBoxContainer/Slot3
@onready var botao_voltar: Button = $Fundo/VBoxContainer/BotaoVoltar
@onready var confirmar: Control = $ConfirmarSobrescrever
@onready var confirmar_mensagem: Label = $ConfirmarSobrescrever/Caixa/VBoxContainer/Mensagem
@onready var confirmar_botao_sim: Button = $ConfirmarSobrescrever/Caixa/VBoxContainer/Botoes/BotaoSim
@onready var confirmar_botao_nao: Button = $ConfirmarSobrescrever/Caixa/VBoxContainer/Botoes/BotaoNao

var modo: int = MODO_NOVO_JOGO
var slot_selecionado: int = -1

signal voltar_pressionado


func _ready() -> void:
	visible = false

	botao_slot_1.pressed.connect(func(): _selecionar_slot(1))
	botao_slot_2.pressed.connect(func(): _selecionar_slot(2))
	botao_slot_3.pressed.connect(func(): _selecionar_slot(3))
	botao_voltar.pressed.connect(fechar)

	confirmar.visible = false
	confirmar_botao_sim.pressed.connect(_on_sobrescrever_confirmado)
	confirmar_botao_nao.pressed.connect(_fechar_confirmacao)


func abrir(novo_modo: int) -> void:
	modo = novo_modo
	visible = true
	atualizar_slots()


func fechar() -> void:
	visible = false
	voltar_pressionado.emit()


func atualizar_slots() -> void:
	titulo.text = "Novo Jogo" if modo == MODO_NOVO_JOGO else "Continuar"

	_atualizar_slot(1, botao_slot_1)
	_atualizar_slot(2, botao_slot_2)
	_atualizar_slot(3, botao_slot_3)


func _atualizar_slot(slot: int, botao: Button) -> void:
	if SaveManager.slot_existe(slot):
		var info = SaveManager.obter_info_slot(slot)
		var data_hora = info.get("data_hora", "")

		botao.text = "Slot %d - %s" % [slot, data_hora]
		botao.disabled = false
	else:
		botao.text = "Slot %d - Vazio" % slot
		
		botao.disabled = (modo == MODO_CONTINUAR)


func _selecionar_slot(slot: int) -> void:
	slot_selecionado = slot

	if modo == MODO_CONTINUAR:
		_continuar_slot(slot)
		return

	if SaveManager.slot_existe(slot):
		confirmar_mensagem.text = "O Slot %d já tem um save.\nSobrescrever e começar um novo jogo?" % slot
		confirmar.visible = true
	else:
		_iniciar_novo_jogo(slot)


func _fechar_confirmacao() -> void:
	confirmar.visible = false


func _on_sobrescrever_confirmado() -> void:
	confirmar.visible = false
	if slot_selecionado != -1:
		_iniciar_novo_jogo(slot_selecionado)


func _iniciar_novo_jogo(slot: int) -> void:
	fechar()
	await SaveManager.novo_jogo(slot)


func _continuar_slot(slot: int) -> void:
	fechar()
	await SaveManager.carregar_jogo(slot)
