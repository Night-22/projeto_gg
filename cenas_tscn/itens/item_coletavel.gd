extends Area2D

@export var item_id: String
@export var item_nome: String
@export var item_icone_path: String
@export var item_quantidade: int = 1
@export_multiline var descricao_desbloqueio: String

var velocidade_coleta := 80.0
var distancia_coleta := 30.0
var coletando := false
var player = null

var altura_flutuacao := 10
var duracao_flutuacao := 0.9

@onready var sprite: AnimatedSprite2D = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	iniciar_flutuacao()
	sprite.play("default")

func iniciar_flutuacao() -> void:
	var y_base = sprite.position.y

	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", y_base - altura_flutuacao, duracao_flutuacao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", y_base + altura_flutuacao, duracao_flutuacao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	var distancia = global_position.distance_to(player.global_position)

	if distancia <= distancia_coleta:
		coletando = true

	if coletando:
		global_position = global_position.move_toward(
			player.global_position,
			velocidade_coleta * delta
		)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	coletar()


func coletar() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if !player.has_method("adicionar_item"):
		return

	player.adicionar_item(item_id, item_nome, item_icone_path, item_quantidade)

	var mostrar_popup := true

	if player.identificar_amuleto(item_id):
		if player.item_ja_foi_visto(item_id):
			mostrar_popup = false
		else:
			player.marcar_item_como_visto(item_id)

	if mostrar_popup:
		var icone = load(item_icone_path) if item_icone_path != "" else null
		DesbloquearItemTela.mostrar_item(item_nome, descricao_desbloqueio, icone)

	queue_free()
