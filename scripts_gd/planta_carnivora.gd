extends Enemy
class_name PlantaCarnivora

enum Estado {
	ESCONDIDA,
	AGITADA,
	MORDENDO,
	VULNERAVEL
}

@export var tempo_agitada := 0.4
@export var tempo_mordida := 0.25
@export var tempo_vulneravel := 1.6
@export var dano_mordida := 2

@onready var anim: AnimatedSprite2D = $anim
@onready var percepcao: Area2D = $percepcao
@onready var boca: Area2D = $boca
@onready var indicador_mordida: Sprite2D = $boca/indicador
@onready var estado_timer: Timer = $EstadoTimer

var estado: Estado = Estado.ESCONDIDA
var player: Node2D = null
var alvos_mordidos: Array = []


func _ready() -> void:
	Speed = 0

	boca.monitoring = false
	boca.body_entered.connect(_on_boca_body_entered)

	indicador_mordida.visible = false

	atualizar_icones_elementais()

	tocar_animacao_estado()


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)


func _on_percepcao_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	player = body

	if estado == Estado.ESCONDIDA:
		iniciar_agitacao()


func _on_percepcao_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func iniciar_agitacao() -> void:
	estado = Estado.AGITADA

	tocar_animacao_estado()

	estado_timer.start(tempo_agitada)


func iniciar_mordida() -> void:
	estado = Estado.MORDENDO

	tocar_animacao_estado()

	alvos_mordidos.clear()
	boca.monitoring = true
	indicador_mordida.visible = true

	morder_se_jogador_ja_estiver_dentro()

	estado_timer.start(tempo_mordida)


func morder_se_jogador_ja_estiver_dentro() -> void:
	for body in boca.get_overlapping_bodies():
		_on_boca_body_entered(body)


func iniciar_vulneravel() -> void:
	estado = Estado.VULNERAVEL

	boca.monitoring = false
	indicador_mordida.visible = false

	tocar_animacao_estado()

	estado_timer.start(tempo_vulneravel)


func voltar_a_esconder() -> void:
	estado = Estado.ESCONDIDA

	tocar_animacao_estado()

	
	if player != null and is_instance_valid(player) and percepcao.overlaps_body(player):
		iniciar_agitacao()


func _on_estado_timer_timeout() -> void:
	match estado:
		Estado.AGITADA:
			iniciar_mordida()

		Estado.MORDENDO:
			iniciar_vulneravel()

		Estado.VULNERAVEL:
			voltar_a_esconder()


func _on_boca_body_entered(body: Node2D) -> void:
	if estado != Estado.MORDENDO:
		return

	if !body.is_in_group("Player"):
		return

	if body in alvos_mordidos:
		return

	alvos_mordidos.append(body)

	if body.has_method("receber_dano"):
		body.receber_dano(dano_mordida, global_position.x)


func _dano(dano: int, origem_x: float, direcao_ataque: Vector2 = Vector2.ZERO) -> void:
	
	if estado != Estado.VULNERAVEL:
		return

	super._dano(dano, origem_x, direcao_ataque)


func tocar_animacao_estado() -> void:
	var nome_animacao := obter_nome_animacao_estado()

	if nome_animacao == "" or anim.sprite_frames == null:
		return

	if not anim.sprite_frames.has_animation(nome_animacao):
		return

	anim.play(nome_animacao)


func obter_nome_animacao_estado() -> String:
	match estado:
		Estado.ESCONDIDA:
			return "escondida"

		Estado.AGITADA:
			return "agitada"

		Estado.MORDENDO:
			return "mordendo"

		Estado.VULNERAVEL:
			return "vulneravel"

	return ""
