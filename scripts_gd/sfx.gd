extends Node

## Gerenciador global de efeitos sonoros.
## Uso: Sfx.play("sword") / Sfx.play_loop("focus_charging") / Sfx.stop_loop("focus_charging")
## Quando existe mais de um arquivo para a mesma ação, um é escolhido aleatoriamente.

const POOL_SIZE := 16

var sounds: Dictionary = {
	"hero_jump": [
		preload("res://assets/sfx/Hero Jump.mp3"),
	],
	"hero_land": [
		preload("res://assets/sfx/Hero Land Soft.mp3"),
	],
	"hero_fall_start": [
		preload("res://assets/sfx/Hero Falling.mp3"),
	],
	"hero_dash": [
		preload("res://assets/sfx/Hero Dash.mp3"),
	],
	"hero_shade_dash": [
		preload("res://assets/sfx/Hero Shade Dash 1.mp3"),
	],
	"footstep_stone": [
		preload("res://assets/sfx/Hero Run Footsteps Stone.mp3"),
	],
	"focus_charging": [
		preload("res://assets/sfx/Focus Health Charging.mp3"),
	],
	"focus_heal": [
		preload("res://assets/sfx/Focus Health Heal.mp3"),
	],
	"enemy_damage": [
		preload("res://assets/sfx/Enemy Damage.mp3"),
	],
	"hero_damage": [
		preload("res://assets/sfx/Hero Damage.mp3"),
	],
	"soul_pickup": [
		preload("res://assets/sfx/Soul Pickup 1.mp3"),
		preload("res://assets/sfx/Soul Pickup 2.mp3"),
		preload("res://assets/sfx/Soul Pickup 3.mp3"),
		preload("res://assets/sfx/Soul Pickup 4.mp3"),
		preload("res://assets/sfx/Soul Pickup 5.mp3"),
		preload("res://assets/sfx/Soul Pickup 6.mp3"),
		preload("res://assets/sfx/Soul Pickup 7.mp3"),
	],
	"sword": [
		preload("res://assets/sfx/Sword 1.mp3"),
		preload("res://assets/sfx/Sword 2.mp3"),
		preload("res://assets/sfx/Sword 3.mp3"),
		preload("res://assets/sfx/Sword 4.mp3"),
		preload("res://assets/sfx/Sword 5.mp3"),
	],
}

var _pool: Array[AudioStreamPlayer] = []
var _loop_players: Dictionary = {} # nome -> AudioStreamPlayer
var _tracked_players: Dictionary = {} # nome -> AudioStreamPlayer (sons não-loop que precisam poder ser parados)


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)


## Toca um efeito sonoro de uma vez. Se houver várias opções para o nome,
## uma delas é escolhida aleatoriamente.
func play(sound_name: String, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name):
		push_warning("Sfx: som '%s' não existe" % sound_name)
		return

	var options: Array = sounds[sound_name]

	if options.is_empty():
		return

	var stream: AudioStream = options[randi() % options.size()]
	var player := _get_free_player()

	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Toca um som em loop (usa um player dedicado por nome, não o pool).
## Se já estiver tocando esse loop, não faz nada.
func play_loop(sound_name: String, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name):
		push_warning("Sfx: som '%s' não existe" % sound_name)
		return

	if _loop_players.has(sound_name) and _loop_players[sound_name].playing:
		return

	var options: Array = sounds[sound_name]

	if options.is_empty():
		return

	var stream: AudioStream = options[0]

	if "loop" in stream:
		stream.loop = true

	var player: AudioStreamPlayer = _loop_players.get(sound_name)

	if player == null:
		player = AudioStreamPlayer.new()
		add_child(player)
		_loop_players[sound_name] = player

	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Para um som que está tocando em loop.
func stop_loop(sound_name: String) -> void:
	if _loop_players.has(sound_name):
		_loop_players[sound_name].stop()


## Toca um som de uma vez, mas usando um player dedicado por nome (não o pool),
## o que permite pará-lo depois com stop_tracked(). Não força loop no stream.
func play_tracked(sound_name: String, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name):
		push_warning("Sfx: som '%s' não existe" % sound_name)
		return

	var options: Array = sounds[sound_name]

	if options.is_empty():
		return

	var stream: AudioStream = options[randi() % options.size()]
	var player: AudioStreamPlayer = _tracked_players.get(sound_name)

	if player == null:
		player = AudioStreamPlayer.new()
		add_child(player)
		_tracked_players[sound_name] = player

	player.stream = stream
	player.volume_db = volume_db
	player.play()


## Para um som iniciado com play_tracked().
func stop_tracked(sound_name: String) -> void:
	if _tracked_players.has(sound_name):
		_tracked_players[sound_name].stop()


func _get_free_player() -> AudioStreamPlayer:
	for player in _pool:
		if not player.playing:
			return player

	# Todos ocupados: rouba o mais antigo (primeiro da lista) para não travar o som.
	return _pool[0]
