extends Node

const CONFIG_PATH := "user://config.cfg"

var volume_master: float = 1.0
var volume_musica: float = 1.0
var volume_sfx: float = 1.0
var mudo: bool = false

var _bus_master := -1
var _bus_musica := -1
var _bus_sfx := -1


func _ready() -> void:
	_bus_master = AudioServer.get_bus_index("Master")
	_bus_musica = AudioServer.get_bus_index("Musica")
	_bus_sfx = AudioServer.get_bus_index("SFX")

	carregar_config()
	aplicar_volumes()


func definir_volume_master(valor: float) -> void:
	volume_master = clamp(valor, 0.0, 1.0)
	aplicar_volumes()
	salvar_config()


func definir_volume_musica(valor: float) -> void:
	volume_musica = clamp(valor, 0.0, 1.0)
	aplicar_volumes()
	salvar_config()


func definir_volume_sfx(valor: float) -> void:
	volume_sfx = clamp(valor, 0.0, 1.0)
	aplicar_volumes()
	salvar_config()


func alternar_mudo(ativo: bool) -> void:
	mudo = ativo
	aplicar_volumes()
	salvar_config()


func aplicar_volumes() -> void:
	if _bus_master != -1:
		AudioServer.set_bus_volume_db(_bus_master, _linear_para_db(volume_master))
		AudioServer.set_bus_mute(_bus_master, mudo)

	if _bus_musica != -1:
		AudioServer.set_bus_volume_db(_bus_musica, _linear_para_db(volume_musica))

	if _bus_sfx != -1:
		AudioServer.set_bus_volume_db(_bus_sfx, _linear_para_db(volume_sfx))


func _linear_para_db(valor: float) -> float:
	if valor <= 0.0:
		return -80.0

	return linear_to_db(valor)


func salvar_config() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master", volume_master)
	config.set_value("audio", "musica", volume_musica)
	config.set_value("audio", "sfx", volume_sfx)
	config.set_value("audio", "mudo", mudo)

	config.save(CONFIG_PATH)


func carregar_config() -> void:
	var config := ConfigFile.new()
	var erro := config.load(CONFIG_PATH)

	if erro != OK:
		return

	volume_master = config.get_value("audio", "master", 1.0)
	volume_musica = config.get_value("audio", "musica", 1.0)
	volume_sfx = config.get_value("audio", "sfx", 1.0)
	mudo = config.get_value("audio", "mudo", false)
