extends Node2D

## Sala final simples do jogo.
## O player chega aqui pela passagem que abre quando o Topgo é derrotado
## (ver sala_boss_topgo.gd -> _abrir_passagem() -> PassagemLateral).
## Aqui o player fica travado, o painel de "fim de jogo" aparece com
## um fade e o botão devolve pro menu principal.

@onready var player: Node2D = get_node_or_null("Player")
@onready var painel_final: CanvasLayer = $PainelFinal
@onready var fundo: ColorRect = $PainelFinal/Fundo
@onready var botao_menu: Button = $PainelFinal/Fundo/VBoxContainer/BotaoMenu

const TEMPO_ESPERA := 1.2
const TEMPO_FADE := 1.4


func _ready() -> void:
	if is_instance_valid(player) and player.has_method("lock_player"):
		player.lock_player()

	fundo.modulate.a = 0.0
	botao_menu.disabled = true
	botao_menu.pressed.connect(_on_botao_menu_pressed)

	await get_tree().create_timer(TEMPO_ESPERA).timeout

	var tween := create_tween()
	tween.tween_property(fundo, "modulate:a", 1.0, TEMPO_FADE)
	tween.tween_callback(func(): botao_menu.disabled = false)


func _on_botao_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas_tscn/menus/main_menu.tscn")
