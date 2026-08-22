extends CanvasLayer

@onready var botao_novo_jogo: Button = $Fundo/VBoxContainer/BotaoNovoJogo
@onready var botao_continuar: Button = $Fundo/VBoxContainer/BotaoContinuar
@onready var botao_opcoes: Button = $Fundo/VBoxContainer/BotaoOpcoes
@onready var botao_sair: Button = $Fundo/VBoxContainer/BotaoSair

@onready var slots_menu = $SlotsMenu
@onready var opcoes_menu = $OpcoesMenu


func _ready() -> void:
	botao_continuar.disabled = SaveManager.obter_ultimo_save() == -1

	botao_novo_jogo.pressed.connect(func(): slots_menu.abrir(slots_menu.MODO_NOVO_JOGO))
	botao_continuar.pressed.connect(func(): slots_menu.abrir(slots_menu.MODO_CONTINUAR))
	botao_opcoes.pressed.connect(opcoes_menu.abrir)
	botao_sair.pressed.connect(_on_sair_pressionado)

	slots_menu.voltar_pressionado.connect(_atualizar_botao_continuar)


func _atualizar_botao_continuar() -> void:
	botao_continuar.disabled = SaveManager.obter_ultimo_save() == -1


func _on_sair_pressionado() -> void:
	get_tree().quit()
