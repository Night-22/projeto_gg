extends Camera2D

@export var camera_suavidade := 7.0
@export var camera_suavidade_queda := 16.0

@onready var player = get_parent()


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = camera_suavidade
	
	drag_vertical_enabled = false


func _process(_delta: float) -> void:
	if player == null:
		return

	if player.camera_travada:
		return

	if player.velocity.y > 0:
		position_smoothing_speed = camera_suavidade_queda
	else:
		position_smoothing_speed = camera_suavidade
