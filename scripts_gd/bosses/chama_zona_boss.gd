extends Area2D
class_name ChamaZonaBoss

@export var largura_total := 120.0
@export var altura := 40.0
@export var tempo_aviso := 0.45
@export var tempo_espalhar := 0.25
@export var tempo_ativo := 1.0
@export var tempo_recolher := 0.3
@export var dano_tick := 2
@export var intervalo_dano := 0.5

@onready var aviso: Node2D = $Aviso
@onready var faixa_aviso: ColorRect = $Aviso/Faixa
@onready var chamas_pivo: Node2D = $ChamasPivo
@onready var chamas_visual: ColorRect = $ChamasPivo/Visual
@onready var hitbox_shape: CollisionShape2D = $CollisionShape2D
@onready var timer_dano: Timer = $TimerDano

var _jogador_dentro := false
var _jogador: Node2D = null


func _ready() -> void:
	monitoring = false
	hitbox_shape.disabled = true

	_montar_visual()

	chamas_pivo.visible = false
	chamas_pivo.scale.x = 0.0

	aviso.visible = true
	faixa_aviso.size = Vector2(largura_total, 6.0)
	faixa_aviso.position = Vector2(-largura_total / 2.0, -6.0)

	_piscar_aviso()

	timer_dano.wait_time = intervalo_dano

	await get_tree().create_timer(tempo_aviso).timeout

	if not is_instance_valid(self):
		return

	_espalhar()


func _montar_visual() -> void:
	chamas_visual.color = Color(1.0, 0.35, 0.15, 0.75)
	chamas_visual.size = Vector2(largura_total, altura)
	chamas_visual.position = Vector2(-largura_total / 2.0, -altura)

	if hitbox_shape.shape is RectangleShape2D:
		hitbox_shape.shape.size = Vector2(largura_total, altura)
		hitbox_shape.position = Vector2(0, -altura / 2.0)


func _piscar_aviso() -> void:
	faixa_aviso.modulate.a = 0.2

	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(faixa_aviso, "modulate:a", 0.9, 0.12)
	tween.tween_property(faixa_aviso, "modulate:a", 0.2, 0.12)


func _espalhar() -> void:
	aviso.visible = false
	chamas_pivo.visible = true

	monitoring = true
	hitbox_shape.disabled = false

	var tween := create_tween()
	tween.tween_property(
		chamas_pivo, "scale:x", 1.0, tempo_espalhar
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.finished.connect(_ativar_dano_continuo)


func _ativar_dano_continuo() -> void:
	timer_dano.start()

	if _jogador_dentro:
		_aplicar_dano()

	await get_tree().create_timer(tempo_ativo).timeout

	if not is_instance_valid(self):
		return

	_recolher()


func _recolher() -> void:
	timer_dano.stop()
	monitoring = false
	hitbox_shape.disabled = true

	var tween := create_tween()
	tween.tween_property(
		chamas_pivo, "scale:x", 0.0, tempo_recolher
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_jogador_dentro = true
		_jogador = body
		_aplicar_dano()


func _on_body_exited(body: Node2D) -> void:
	if body == _jogador:
		_jogador_dentro = false
		_jogador = null


func _on_timer_dano_timeout() -> void:
	if _jogador_dentro:
		_aplicar_dano()


func _aplicar_dano() -> void:
	if _jogador and is_instance_valid(_jogador) and _jogador.has_method("receber_dano"):
		_jogador.receber_dano(dano_tick, global_position.x)
