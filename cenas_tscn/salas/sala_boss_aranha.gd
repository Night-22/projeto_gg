extends Node2D

@onready var boss: AranhaBoss = get_node("AranhaBoss")
@onready var gatilho: Area2D = $GatilhoLuta
@onready var hud_chefe: CanvasLayer = $HudChefe
@onready var barra_vida_chefe: ProgressBar = $HudChefe/Interface/BarraVidaChefe
@onready var nome_chefe: Label = $HudChefe/Interface/NomeChefe
@onready var soundtrack: AudioStreamPlayer = $soundtrack

const ID_CHEFE := "aranha"

var luta_iniciada := false


func _ready() -> void:
	hud_chefe.visible = false

	if boss:
		boss.chefe_derrotado.connect(_on_chefe_derrotado)

	if GerenciadorChefes.foi_derrotado(ID_CHEFE):
		_configurar_sala_com_chefe_ja_morto()


func _process(_delta: float) -> void:
	if not luta_iniciada:
		return

	if not is_instance_valid(boss):
		return

	barra_vida_chefe.max_value = boss.vida_maxima_boss
	barra_vida_chefe.value = max(boss.Life, 0)


func _on_gatilho_luta_body_entered(body: Node2D) -> void:
	if luta_iniciada:
		return

	if not body.is_in_group("Player"):
		return

	luta_iniciada = true
	hud_chefe.visible = true
	#gatilho.monitoring = false

	if boss:
		boss.iniciar_luta()
		soundtrack.play()
		


func _on_chefe_derrotado() -> void:
	nome_chefe.text = "ARANHA DERROTADA"

	GerenciadorChefes.marcar_derrotado(ID_CHEFE)
	_apagar_musica_chefe()
	_abrir_passagem()

	await get_tree().create_timer(4.0).timeout

	if is_instance_valid(hud_chefe):
		hud_chefe.visible = false


func _configurar_sala_com_chefe_ja_morto() -> void:
	if is_instance_valid(boss):
		boss.dead = true
		boss.visible = false
		boss.set_physics_process(false)
		boss.set_collision_layer_value(1, false)
		boss.set_collision_mask_value(1, false)

	if is_instance_valid(gatilho):
		gatilho.monitoring = false

	_abrir_passagem(true)


func _apagar_musica_chefe() -> void:
	if not is_instance_valid(soundtrack) or not soundtrack.playing:
		return

	var tween := create_tween()
	tween.tween_property(soundtrack, "volume_db", -40.0, 2.0)
	tween.tween_callback(soundtrack.stop)


func _abrir_passagem(instantaneo: bool = false) -> void:
	var passagem := get_node_or_null("PassagemLateral")

	if passagem and passagem.has_method("abrir"):
		passagem.abrir(instantaneo)
