extends Flying

@export var distancia_seguimento: float = 5.0

@onready var percepcao: Area2D = $percepcao
@onready var anim: AnimatedSprite2D = $anim

var player: CharacterBody2D = null
var player_detectado: bool = false


func _physics_process(delta: float) -> void:
	if dead:
		return

	if knockback.length() > 10.0:
		velocity = knockback
		
		knockback = knockback.move_toward(
			Vector2.ZERO,
			500.0 * delta
		)
	
	elif player_detectado and is_instance_valid(player):
		var distancia_x = player.global_position.x - global_position.x
		var distancia_y = player.global_position.y - global_position.y
		
		if abs(distancia_x) > distancia_seguimento:
			dir = sign(distancia_x)
			velocity.x = dir * Speed
		else:
			velocity.x = 0.0
		
		velocity.y = distancia_y * 3.0
	
	else:
		velocity.x = dir * Speed
		velocity.y = 0.0
	
	move_and_slide()
	
	if velocity.length() > 1.0:
		anim.play("voo")
	
	if is_on_wall() and not player_detectado:
		dir *= -1
