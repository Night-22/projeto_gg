extends Area2D
class_name Alavanca

@onready var sprite = $AnimatedSprite2D

var ativa := false
var jogador_perto := false
var posicao_inicial: Vector2

@onready var label = get_node("Label")

func _ready():
	posicao_inicial = position




func _physics_process(_delta: float) -> void:
	if jogador_perto and Input.is_action_just_pressed("interagir") and not ativa:
		ativa = true
		print("ALAVANCA ATIVA: ", ativa)

		sprite.play("ligando")

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "position:x", posicao_inicial.x + 1, 0.05)
		tween.tween_property(self, "position:x", posicao_inicial.x - 1, 0.05)
		tween.tween_property(self, "position:x", posicao_inicial.x, 0.05)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jogador_perto = false
