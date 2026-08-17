extends StaticBody2D
class_name Porta

signal destrancou

@export var fechada: bool
@export var alavanca: int
@export var alavancas: Array[Node2D] = []

@onready var sprite = $porta
@onready var colisao = $CollisionShape2D

var posicao_inicial: Vector2
var jogador_perto := false

@onready var label = get_node("Label")
func _ready():
	posicao_inicial = position
	label.modulate.a = 0.0
	
	if fechada:
		fechar()
	else:
		abrir()

func abrir():
	fechada = false
	sprite.play("aberta")
	colisao.disabled = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", posicao_inicial.x + 1, 0.05)
	tween.tween_property(self, "position:x", posicao_inicial.x - 1, 0.05)
	tween.tween_property(self, "position:x", posicao_inicial.x, 0.05)
	


func fechar():
	fechada = true
	sprite.play("fechada")
	colisao.disabled = false


func _process(_delta):
	if not alavancas.is_empty():
		var todas_ativas := true

		for alavanca in alavancas:
			if not alavanca.ativa:
				todas_ativas = false
				break

		if todas_ativas:
			destrancou.emit()
			alavancas.clear()

	if jogador_perto and Input.is_action_just_pressed("interagir"):
		if fechada and not alavancas.is_empty():
			for alavanca in alavancas:
				if not alavanca.ativa:
					mostrar_alavancas()

					var tween = create_tween()
					tween.set_trans(Tween.TRANS_SINE)
					tween.tween_property(self, "position:x", posicao_inicial.x + 1, 0.05)
					tween.tween_property(self, "position:x", posicao_inicial.x - 1, 0.05)
					tween.tween_property(self, "position:x", posicao_inicial.x, 0.05)

					return

		if fechada:
			abrir()
		else:
			fechar()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = false

func mostrar_alavancas():
	if alavancas.size() <= 1:
		return

	var ativas := 0

	for alavanca in alavancas:
		if alavanca.ativa:
			ativas += 1

	if ativas >= alavancas.size():
		return

	label.text = str(ativas) + "/" + str(alavancas.size())
	label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
