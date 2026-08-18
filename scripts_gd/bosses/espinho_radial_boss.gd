extends Node2D
class_name EspinhoRadialBoss



@export var numero_direcoes := 7
@export var comprimento := 260.0
@export var largura := 26.0
@export var dano := 3
@export var tempo_aviso := 0.45
@export var tempo_ativo := 0.35

@export var angulo_inicial_graus := -90.0

var _pontas: Array[Area2D] = []


func _ready() -> void:
	_montar_pontas()

	await get_tree().create_timer(tempo_aviso).timeout

	if not is_instance_valid(self):
		return

	_emergir()


func _montar_pontas() -> void:
	var passo := TAU / float(numero_direcoes)

	for i in range(numero_direcoes):
		var angulo := deg_to_rad(angulo_inicial_graus) + passo * i
		var ponta := _criar_ponta()

		ponta.rotation = angulo

		add_child(ponta)
		_pontas.append(ponta)


func _criar_ponta() -> Area2D:
	var area := Area2D.new()
	area.monitoring = false

	var linha_aviso := Line2D.new()
	linha_aviso.name = "LinhaAviso"
	linha_aviso.points = PackedVector2Array([Vector2.ZERO, Vector2(0, -comprimento)])
	linha_aviso.width = 3.0
	linha_aviso.default_color = Color(1.0, 0.4, 0.3, 0.65)
	area.add_child(linha_aviso)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.color = Color(0.5, 1.0, 0.45, 0.9)
	visual.polygon = PackedVector2Array([
		Vector2(-largura / 2.0, 0.0),
		Vector2(largura / 2.0, 0.0),
		Vector2(0.0, -comprimento),
	])
	visual.scale.y = 0.05
	area.add_child(visual)

	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var retangulo := RectangleShape2D.new()
	retangulo.size = Vector2(largura, comprimento)
	shape.shape = retangulo
	shape.position = Vector2(0, -comprimento / 2.0)
	shape.disabled = true
	area.add_child(shape)

	area.set_meta("atingiu", false)
	area.body_entered.connect(_on_ponta_body_entered.bind(area))

	return area


func _emergir() -> void:
	for area in _pontas:
		if not is_instance_valid(area):
			continue

		var linha_aviso: Line2D = area.get_node("LinhaAviso")
		var visual: Polygon2D = area.get_node("Visual")
		var shape: CollisionShape2D = area.get_node("CollisionShape2D")

		linha_aviso.visible = false

		area.monitoring = true
		shape.disabled = false

		var tween := create_tween()
		tween.tween_property(
			visual, "scale:y", 1.0, 0.08
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(tempo_ativo).timeout

	if is_instance_valid(self):
		queue_free()


func _on_ponta_body_entered(body: Node2D, area: Area2D) -> void:
	if area.get_meta("atingiu", false):
		return

	if body.is_in_group("Player") and body.has_method("receber_dano"):
		area.set_meta("atingiu", true)
		body.receber_dano(dano, global_position.x)
