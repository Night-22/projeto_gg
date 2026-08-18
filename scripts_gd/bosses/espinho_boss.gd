extends Area2D
class_name EspinhoBoss

@export var largura := 200.0
@export var altura := 260.0
@export var tempo_aviso := 0.4
@export var tempo_ativo := 0.55
@export var dano := 6
@export var numero_pontas := 6

@onready var aviso: Node2D = $Aviso
@onready var faixa_aviso: ColorRect = $Aviso/Faixa
@onready var espinhos: Node2D = $Espinhos
@onready var hitbox_shape: CollisionShape2D = $CollisionShape2D

var _jogador_dentro := false


func _ready() -> void:
	monitoring = false
	hitbox_shape.disabled = true

	_montar_visual()

	espinhos.visible = false
	aviso.visible = true

	_piscar_aviso()

	await get_tree().create_timer(tempo_aviso).timeout

	if not is_instance_valid(self):
		return

	_emergir()


func _montar_visual() -> void:
	for filho in espinhos.get_children():
		filho.queue_free()

	if faixa_aviso:
		faixa_aviso.position = Vector2(-largura / 2.0, -5.0)
		faixa_aviso.size = Vector2(largura, 5.0)

	var largura_ponta := largura / float(numero_pontas)

	for i in range(numero_pontas):
		var ponta := Polygon2D.new()

		var x0 := -largura / 2.0 + i * largura_ponta
		var x1 := x0 + largura_ponta
		var xm := (x0 + x1) / 2.0

		var cor_variacao := randf_range(-0.08, 0.08)
		ponta.color = Color(0.22 + cor_variacao, 0.6 + cor_variacao, 0.22, 1.0)

		ponta.polygon = PackedVector2Array([
			Vector2(x0 + 2.0, 0.0),
			Vector2(x1 - 2.0, 0.0),
			Vector2(xm, -altura),
		])

		espinhos.add_child(ponta)

	if hitbox_shape and hitbox_shape.shape is RectangleShape2D:
		hitbox_shape.shape.size = Vector2(largura - 6.0, altura)
		hitbox_shape.position = Vector2(0, -altura / 2.0)


func _piscar_aviso() -> void:
	if not faixa_aviso:
		return

	faixa_aviso.modulate.a = 0.15

	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(faixa_aviso, "modulate:a", 0.75, 0.14)
	tween.tween_property(faixa_aviso, "modulate:a", 0.15, 0.14)


func _emergir() -> void:
	aviso.visible = false
	espinhos.visible = true
	espinhos.scale.y = 0.05

	monitoring = true
	hitbox_shape.disabled = false

	var tween := create_tween()
	tween.tween_property(
		espinhos, "scale:y", 1.0, 0.1
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(tempo_ativo).timeout

	if not is_instance_valid(self):
		return

	_recolher()


func _recolher() -> void:
	monitoring = false
	hitbox_shape.disabled = true

	var tween := create_tween()
	tween.tween_property(
		espinhos, "scale:y", 0.0, 0.18
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)


func _on_body_entered(body: Node2D) -> void:
	if _jogador_dentro:
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		_jogador_dentro = true
		body.receber_dano(dano, global_position.x)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_jogador_dentro = false
