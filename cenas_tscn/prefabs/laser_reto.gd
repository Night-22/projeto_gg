extends Area2D

@export var tempo_ligado: float = 1.5
@export var tempo_desligado: float = 1.5
@export var dano: int = 10
@export var intervalo_dano: float = 0.5

@export var tamanho_minimo: float = 16.0
@export var margem: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var ligado := false
var pode_dar_dano := true
var jogadores_dentro := []


func _ready() -> void:
	sprite.centered = false

	desligar()
	ciclo_laser()


func atualizar_tamanho() -> void:
	raycast.force_raycast_update()

	var distancia := raycast.target_position.x

	if raycast.is_colliding():
		var ponto_colisao := raycast.get_collision_point()

		# distância exata até a parede
		distancia = ponto_colisao.x - global_position.x

		# deixa 1 pixel antes da parede
		distancia -= margem

	distancia = max(distancia, tamanho_minimo)

	if sprite.texture:
		sprite.scale.x = distancia / sprite.texture.get_width()


func ciclo_laser() -> void:
	while is_inside_tree():
		await get_tree().create_timer(tempo_desligado).timeout
		ligar()

		await get_tree().create_timer(tempo_ligado).timeout
		desligar()


func ligar() -> void:
	ligado = true
	anim.play("ligado")

	atualizar_tamanho()

	sprite.visible = true
	collision_shape.set_deferred("disabled", false)

	for jogador in jogadores_dentro:
		if is_instance_valid(jogador):
			dar_dano(jogador)


func desligar() -> void:
	ligado = false
	anim.play("desligado")

	sprite.visible = false
	collision_shape.set_deferred("disabled", true)


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	if body not in jogadores_dentro:
		jogadores_dentro.append(body)

	if ligado:
		dar_dano(body)


func _on_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	jogadores_dentro.erase(body)


func dar_dano(jogador: Node2D) -> void:
	if !pode_dar_dano:
		return

	if jogador.has_method("receber_dano"):
		jogador.receber_dano(dano, global_position.x)

	pode_dar_dano = false

	await get_tree().create_timer(intervalo_dano).timeout

	pode_dar_dano = true

	if ligado:
		for jogador_dentro in jogadores_dentro:
			if is_instance_valid(jogador_dentro):
				dar_dano(jogador_dentro)
