extends Area2D

enum TipoAlma {
	AGUA,
	FOGO,
	RAIO,
	PLANTA
}

var tipo: TipoAlma = TipoAlma.AGUA

var velocidade_coleta := 250.0
var distancia_coleta := 80.0
var coletando := false
var player = null

var agua_icon = preload("res://placeholder/agua.png")
var fogo_icon = preload("res://placeholder/fogo.png")
var raio_icon = preload("res://placeholder/raio.png")
var planta_icon = preload("res://placeholder/planta.png")

@onready var sprite: Sprite2D = $Sprite2D


func configurar(novo_tipo: TipoAlma) -> void:
	tipo = novo_tipo
	atualizar_icone()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	atualizar_icone()


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


func atualizar_icone() -> void:
	if sprite == null:
		return

	match tipo:
		TipoAlma.AGUA:
			sprite.texture = agua_icon

		TipoAlma.FOGO:
			sprite.texture = fogo_icon

		TipoAlma.RAIO:
			sprite.texture = raio_icon

		TipoAlma.PLANTA:
			sprite.texture = planta_icon


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	coletar()


func coletar() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")

	if player == null:
		return

	if player.has_method("adicionar_alma"):
		player.adicionar_alma(tipo)

	queue_free()
