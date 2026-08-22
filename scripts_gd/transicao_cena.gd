extends Area2D


enum Zona {
	ZONA_TUTORIAL,
	ZONA_AGUA,
	ZONA_NEUTRA,
	ZONA_RAIO,
	ZONA_TERRA,
	SALA_BOSS_ARANHA,
	SALA_BOSS_RAIO,
	SALA_BOSS_TOPGO
}


@export var cena_destino: Zona = Zona.ZONA_NEUTRA
@export var entrada_destino: String = ""


var zonas = {
	Zona.ZONA_TUTORIAL:
		preload("res://cenas_tscn/tutorial.tscn"),

	Zona.ZONA_AGUA:
		preload("res://cenas_tscn/zona_agua.tscn"),

	Zona.ZONA_NEUTRA:
		preload("res://cenas_tscn/zona_neutra.tscn"),

	Zona.ZONA_RAIO:
		preload("res://cenas_tscn/zona_raio.tscn"),

	Zona.ZONA_TERRA:
		preload("res://cenas_tscn/zona_terra.tscn"),

	Zona.SALA_BOSS_ARANHA:
		preload("res://cenas_tscn/salas/sala_boss_aranha.tscn"),

	Zona.SALA_BOSS_RAIO:
		preload("res://cenas_tscn/salas/sala_boss_raio.tscn"),

	Zona.SALA_BOSS_TOPGO:
		preload("res://cenas_tscn/salas/sala_boss_topgo.tscn")
}


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	body.lock_player()

	var cena = zonas.get(cena_destino)

	if cena == null:
		print("cena de destino invalida.")
		body.unlock_player()
		return

	await Transicao.trocar_cena(
		cena.resource_path,
		entrada_destino
	)

	body.unlock_player()
	
