extends PathFollow2D

@export var velocidade := 50.0
@export var suavidade := 8.0

@export var voltar_por_tp := false

@export var laser_color = Color.WHITE

var alvo := 0.0
var direcao := 1.0
var active := true
var tween_duration := 0.15

@onready var caminho: Path2D = get_parent()

@onready var hit_impact: RayCast2D = get_node("hit_impact")
@onready var laser_line: Line2D = get_node("laser_line")
@onready var impact_fx: GPUParticles2D = get_node("GPUParticles2D")
@onready var anim: AnimatedSprite2D = get_node("torreta")


func _ready() -> void:
	alvo = progress

	laser_line.visible = true
	#laser_line.modulate = laser_color

	if impact_fx.process_material:
		impact_fx.process_material.set("color", laser_color)

	impact_fx.top_level = true

	fire()


func _process(delta: float) -> void:
	if caminho.curve == null:
		return

	var comprimento := caminho.curve.get_baked_length()

	if comprimento <= 0.0:
		return

	alvo += direcao * velocidade * delta

	if voltar_por_tp:
		if alvo >= comprimento:
			alvo = 0.0
			progress_ratio = 0.0
			direcao = 1.0
		else:
			progress = lerp(progress, alvo, suavidade * delta)

	else:
		if alvo >= comprimento:
			alvo = comprimento
			direcao = -1.0

		elif alvo <= 0.0:
			alvo = 0.0
			direcao = 1.0

		progress = lerp(progress, alvo, suavidade * delta)


func _physics_process(_delta: float) -> void:
	if !active:
		return

	atualizar_laser()
	acertou_jogador()


func atualizar_laser() -> void:
	hit_impact.force_raycast_update()

	var ponto_global := hit_impact.to_global(hit_impact.target_position)

	if hit_impact.is_colliding():
		ponto_global = hit_impact.get_collision_point()

		impact_fx.global_position = ponto_global
		impact_fx.emitting = true
	else:
		impact_fx.emitting = false

	var ponto_local := laser_line.to_local(ponto_global)

	laser_line.points = PackedVector2Array([
		laser_line.to_local(hit_impact.global_position),
		ponto_local
	])


func fire() -> void:
	anim.play("ligado")

	active = true
	laser_line.visible = true

	atualizar_laser()


func acertou_jogador() -> void:
	if !hit_impact.is_colliding():
		return

	var objeto := hit_impact.get_collider()

	if objeto.is_in_group("Player"):
		objeto.receber_dano(5, global_position.x * 0.5)
		return

	var pai = objeto.get_parent()

	if pai != null and pai.is_in_group("Player"):
		pai.receber_dano(5, global_position.x * 0.5)
