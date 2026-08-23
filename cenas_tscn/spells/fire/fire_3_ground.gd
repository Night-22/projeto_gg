extends Node2D

var duration = 3.0
var damage = 5

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var duration_timer: Timer = $DurationTimer
@onready var area: Area2D = $Area2D


func iniciar(tempo: float) -> void:
	duration = tempo
	duration_timer.start(duration)
	sprite.visible = true
	sprite.play("default")

func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Inimigo"):
		return

	var dano = damage

	if body.has_method("_aplicar_elemento"):
		dano = body._aplicar_elemento(
			0,
			dano,
			global_position.x
		)

	body._dano(dano, global_position.x)


func _on_duration_timer_timeout() -> void:
	queue_free()
