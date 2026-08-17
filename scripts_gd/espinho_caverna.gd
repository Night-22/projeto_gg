extends StaticBody2D

@export var dano = 5
@export var gravidade = 1200.0
@export var velocidade_queda_max = 800.0

@onready var raycast = $RayCast2D
@onready var raycast_chao = $RayCastChao
@onready var area = $Area2D
@onready var colisao = $CollisionShape2D

var caindo = false
var caiu_no_chao = false
var velocidade_y = 0.0


func _ready():
	# não colide enquanto espera ou cai
	colisao.disabled = true


func _physics_process(delta):
	# detecta o jogador e começa a cair
	if not caindo and not caiu_no_chao:
		if raycast.is_colliding():
			var alvo = raycast.get_collider()

			if alvo.is_in_group("Player"):
				caindo = true
				area.monitoring = true
				velocidade_y = 0.0

	# faz o objeto cair
	if caindo:
		# aplica a gravidade
		velocidade_y += gravidade * delta
		velocidade_y = min(velocidade_y, velocidade_queda_max)

		# continua caindo
		position.y += velocidade_y * delta

		# só para quando chega no chão
		if raycast_chao.is_colliding():
			caindo = false
			caiu_no_chao = true
			velocidade_y = 0.0

			# ativa a colisão no chão
			colisao.disabled = false

			# para de dar dano
			area.monitoring = false


func _on_area_2d_body_entered(body):
	# o jogador toma dano, mas o objeto continua caindo
	if caindo and body.is_in_group("Player"):
		body.receber_dano(dano, global_position.x)
