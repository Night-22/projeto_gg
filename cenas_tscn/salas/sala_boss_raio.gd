extends Node2D

@onready var boss: RaioBoss = $RaioBoss
@onready var gatilho: Area2D = $GatilhoLuta
@onready var hud_chefe: CanvasLayer = $HudChefe
@onready var barra_vida_chefe: ProgressBar = $HudChefe/Interface/BarraVidaChefe
@onready var nome_chefe: Label = $HudChefe/Interface/NomeChefe

var luta_iniciada := false


func _ready() -> void:
	hud_chefe.visible = false

	if boss:
		boss.chefe_derrotado.connect(_on_chefe_derrotado)


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

	if boss:
		boss.iniciar_luta()


func _on_chefe_derrotado() -> void:
	nome_chefe.text = "CHEFE DE RAIO DERROTADO"

	await get_tree().create_timer(4.0).timeout

	if is_instance_valid(hud_chefe):
		hud_chefe.visible = false
