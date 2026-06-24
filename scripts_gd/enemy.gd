extends CharacterBody2D
class_name Enemy

@export var Life = 5
@export var Speed = 60
@export var JUMP_FORCE = -200
@export var dir = -1

@export var knockback_force := 200
@export var knockback_up_force := -140

var dead := false
var ataqueRecebidos = []

var knockback := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if knockback.length() > 10:
		velocity.x = knockback.x
		knockback.x = move_toward(knockback.x, 0, 500 * delta)
	else:
		velocity.x = dir * Speed

	move_and_slide()

	if is_on_wall():
		dir *= -1


# Começo das reações de elementos

func receberAtaque(tipo):
	const tiposVariados = ["planta","água","fogo","raio"]

	if tipo in tiposVariados:
		ataqueRecebidos.append(tipo)
		print("Ataque de ", tipo, " registrado")
	else:
		print("não tem tipo esse ataque")


func _dano(dano: int, origem_x: float):
	if dead:
		return
	
	Life -= dano
	
	var direcao = sign(global_position.x - origem_x)
	knockback.x = direcao * knockback_force
	velocity.y = knockback_up_force
	
	if Life <= 0:
		die()


func die():
	dead = true
	queue_free()
