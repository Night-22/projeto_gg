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
		"res://cenas_tscn/tutorial.tscn",

	Zona.ZONA_AGUA:
		"res://cenas_tscn/zona_agua.tscn",

	Zona.ZONA_NEUTRA:
		"res://cenas_tscn/zona_neutra.tscn",

	Zona.ZONA_RAIO:
		"res://cenas_tscn/zona_raio.tscn",

	Zona.ZONA_TERRA:
		"res://cenas_tscn/zona_terra.tscn",

	Zona.SALA_BOSS_ARANHA:
		"res://cenas_tscn/salas/sala_boss_aranha.tscn",

	Zona.SALA_BOSS_RAIO:
		"res://cenas_tscn/salas/sala_boss_raio.tscn",

	Zona.SALA_BOSS_TOPGO:
		"res://cenas_tscn/salas/sala_boss_topgo.tscn"
}


func _on_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return

	body.lock_player()

	var caminho_cena = zonas.get(cena_destino)

	if caminho_cena == null:
		print("cena de destino invalida.")
		body.unlock_player()
		return

	await Transicao.trocar_cena(
		caminho_cena,
		entrada_destino
	)

	body.unlock_player()
