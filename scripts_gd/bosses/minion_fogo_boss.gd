extends Enemy
class_name MinionFogoBoss



@export var knockback_explosivo := 260.0
@export var knockback_explosivo_up := -240.0
@export var dano_explosao := 6
@export var tempo_aviso_explosao := 0.15
@export var tempo_ativo_explosao := 0.12

@export var tempo_vida_maxima := 15.0

@onready var area_explosao: Area2D = $AreaExplosao
@onready var explosao_shape: CollisionShape2D = $AreaExplosao/CollisionShape2D

@onready var visual: AnimatedSprite2D = $Visual


var atingido := false
var explodindo := false


func _ready() -> void:
	super._ready()

	visual.play("default")

	Speed = 0
	dir = 0
	max_elementos = 2

	area_explosao.monitoring = false
	explosao_shape.disabled = true

	get_tree().create_timer(tempo_vida_maxima).timeout.connect(_expirar)


func _physics_process(delta: float) -> void:
	if dead or explodindo:
		return

	super._physics_process(delta)


func _dano(dano: int, origem_x: float, _direcao_ataque: Vector2 = Vector2.ZERO) -> void:
	if dead or explodindo:
		return

	mostrar_dano(dano)

	piscar_dano()

	var direcao := signf(global_position.x - origem_x)
	if direcao == 0.0:
		direcao = 1.0

	knockback.x = direcao * knockback_explosivo
	velocity.y = knockback_explosivo_up

	if not atingido:
		atingido = true
		_esperar_pouso()



func remover_sem_explodir() -> void:
	if dead or explodindo:
		return

	dead = true
	queue_free()


func _expirar() -> void:
	if not atingido:
		remover_sem_explodir()


func _esperar_pouso() -> void:
	
	await get_tree().create_timer(0.12).timeout

	while is_instance_valid(self) and not dead and not explodindo and not is_on_floor():
		await get_tree().physics_frame

	if is_instance_valid(self) and not dead and not explodindo:
		_explodir()


func _explodir() -> void:
	if explodindo:
		return

	explodindo = true
	velocity = Vector2.ZERO
	modulate = Color(1.4, 0.9, 0.6)

	await get_tree().create_timer(tempo_aviso_explosao).timeout

	if not is_instance_valid(self):
		return

	area_explosao.monitoring = true
	explosao_shape.disabled = false

	await get_tree().create_timer(tempo_ativo_explosao).timeout

	if not is_instance_valid(self):
		return

	dead = true
	queue_free()


func _on_area_explosao_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("receber_dano"):
		body.receber_dano(dano_explosao, global_position.x)
