extends Camera2D

@export var camera_suavidade := 7.0
@export var camera_suavidade_queda := 16.0

@onready var player = get_parent()

var shake_strength := 0.0
var shake_timer := 0.0
var shake_duration_atual := 0.0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = camera_suavidade
	
	drag_vertical_enabled = false


func _process(delta: float) -> void:
	_process_shake(delta)

	if player == null:
		return

	if player.camera_travada:
		return

	if player.velocity.y > 0:
		position_smoothing_speed = camera_suavidade_queda
	else:
		position_smoothing_speed = camera_suavidade


# Mini screen shake, usado por exemplo ao terminar de curar.
# strength = intensidade em pixels, duration = quanto tempo dura o tremor.
func shake(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_duration_atual = max(duration, 0.001)
	shake_timer = shake_duration_atual


func _process_shake(delta: float) -> void:
	if shake_timer <= 0.0:
		return

	shake_timer = max(shake_timer - delta, 0.0)

	var falloff = shake_timer / shake_duration_atual

	if shake_timer <= 0.0:
		offset = Vector2.ZERO
	else:
		offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength * falloff
