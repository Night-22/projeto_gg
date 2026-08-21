extends Node2D

@onready var hit_impact := get_node("hit_impact")
@onready var laser_line := get_node("laser_line")
@onready var impact_fx = get_node("GPUParticles2D")
@onready var timer = get_node("Timer")
@onready var anim = get_node("torreta")


@export var laser_color = Color.WHITE : set = set_laser_color

var active := false
var tween_duration := 0.15



func _ready() -> void:
	laser_line.visible = false
	set_laser_color(laser_color)

func _physics_process(delta: float) -> void:
	if !active:
		return
	
	var end_point = hit_impact.target_position
	if hit_impact.is_colliding():
		end_point = to_local(hit_impact.get_collision_point())
		impact_fx.global_position= hit_impact.get_collision_point()
		impact_fx.emitting = true
		acertou_jogador()
	
	
	laser_line.points[0] = Vector2.ZERO
	laser_line.points[1] = end_point
	
func fire():
	anim.play("ligado")
	active = true
	laser_line.visible = true
	hit_impact.force_raycast_update()
	
	var target = hit_impact.target_position
	if hit_impact.is_colliding():
		target = to_local(hit_impact.get_collision_point())
		impact_fx.global_position = hit_impact.get_collision_point()
		impact_fx.emitting = true
		
	laser_line.points = PackedVector2Array([Vector2.ZERO, Vector2.ZERO])
	var tween = create_tween()
	var final_points = PackedVector2Array([Vector2.ZERO, target])
	tween.tween_property(laser_line, "points", final_points, tween_duration)

func set_laser_color(new_color: Color) -> void:
	laser_color = new_color
	
	if !laser_line:
		return
	
	laser_line.modulate = new_color
	impact_fx.process_material.set("color", new_color)
	
	


func stop():
	anim.play("desligado")
	active = false
	impact_fx.emitting = false
	
	var tween = create_tween()
	tween.tween_property(laser_line, "points", PackedVector2Array([Vector2.ZERO, Vector2.ZERO]), tween_duration)
	await tween.finished
	laser_line.visible = false

func _on_timer_timeout() -> void:
	if active:
		stop()
	else:
		fire()
	
	timer.start()
	
	
func acertou_jogador() -> void:
	if !hit_impact.is_colliding():
		return

	var objeto = hit_impact.get_collider()

	if objeto.is_in_group("Player"):
		objeto.receber_dano(5, global_position.x)
