extends Area2D

@export var player : CharacterBody2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.entrar_na_agua()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.sair_da_agua()
