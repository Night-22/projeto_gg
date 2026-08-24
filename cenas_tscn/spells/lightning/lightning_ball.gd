extends Area2D

var player = null

var damage = 8
var damage_cooldown = 0.5

var enemies_hit = {}


func setup(owner_player) -> void:
	player = owner_player


func _process(delta: float) -> void:
	var expired = []

	for enemy in enemies_hit:
		enemies_hit[enemy] -= delta

		if enemies_hit[enemy] <= 0:
			expired.append(enemy)

	for enemy in expired:
		enemies_hit.erase(enemy)


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Inimigo"):
		return

	if enemies_hit.has(body):
		return

	if body.has_method("_aplicar_elemento"):
		damage = body._aplicar_elemento(
			2,
			damage,
			global_position.x
		)

	body._dano(damage, global_position.x)

	enemies_hit[body] = damage_cooldown
