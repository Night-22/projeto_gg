extends PathFollow2D

@export var velocidade := 50.0
@export var tempo_ligado: float = 1.5
@export var tempo_desligado: float = 1.5

@export var posicao_inicial := 0.0

@onready var sprite = get_node("Area2D/Sprite2D")
@onready var anim = get_node("Area2D/AnimatedSprite2D")

var indo = true
var ligado := false

func _ready() -> void:
	progress = posicao_inicial
	
	desligar()
	ciclo_laser()

func ciclo_laser() -> void:
	while is_inside_tree():
		await get_tree().create_timer(tempo_desligado).timeout
		ligar()

		await get_tree().create_timer(tempo_ligado).timeout
		desligar()

func ligar() -> void:
	ligado = true
	sprite.visible = true
	anim.play("ligado")

func desligar() -> void:
	ligado = false
	sprite.visible = false
	anim.play("desligado")

func _process(delta):
	var caminho = get_parent().curve

	if caminho == null:
		return

	var comprimento = caminho.get_baked_length()

	if indo:
		progress += velocidade * delta

		if progress >= comprimento:
			progress = comprimento
			indo = false
	else:
		progress -= velocidade * delta

		if progress <= 0:
			progress = 0
			indo = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if ligado and body.is_in_group("Player"):
		body.receber_dano(10, global_position.x)
