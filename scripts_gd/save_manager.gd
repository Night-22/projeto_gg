extends Node

const SAVE_DIR = "user://saves/"
const MAX_SLOTS = 3


func _ready() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _caminho_slot(slot: int) -> String:
	return SAVE_DIR + "slot_%d.save" % slot


func slot_existe(slot: int) -> bool:
	return FileAccess.file_exists(_caminho_slot(slot))


func obter_info_slot(slot: int) -> Dictionary:
	if !slot_existe(slot):
		return {}

	var file = FileAccess.open(_caminho_slot(slot), FileAccess.READ)

	if file == null:
		return {}

	var texto = file.get_as_text()
	file.close()

	var json = JSON.new()

	if json.parse(texto) != OK:
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		return {}

	return json.data



func salvar_jogo(slot: int, player) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		return false

	if player == null or !is_instance_valid(player):
		return false

	if !player.has_method("obter_dados_save"):
		return false

	var dados: Dictionary = player.obter_dados_save()
	dados["data_hora"] = Time.get_datetime_string_from_system()

	var file = FileAccess.open(_caminho_slot(slot), FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(JSON.stringify(dados))
	file.close()

	return true


func carregar_jogo(slot: int) -> bool:
	if !slot_existe(slot):
		return false

	var dados = obter_info_slot(slot)

	if dados.is_empty():
		return false

	var cena_alvo: String = dados.get("checkpoint_cena", "")
	var cena_atual = get_tree().current_scene

	var precisa_trocar_cena = (
		cena_alvo != ""
		and (cena_atual == null or cena_atual.scene_file_path != cena_alvo)
	)

	if precisa_trocar_cena:
		get_tree().change_scene_to_file(cena_alvo)

		
		await get_tree().process_frame
		await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("Player")

	if player == null or !is_instance_valid(player):
		return false

	if player.has_method("aplicar_dados_save"):
		player.aplicar_dados_save(dados)

	get_tree().paused = false

	return true


func apagar_slot(slot: int) -> void:
	if slot_existe(slot):
		DirAccess.remove_absolute(_caminho_slot(slot))
