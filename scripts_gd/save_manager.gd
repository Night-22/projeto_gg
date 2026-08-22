extends Node

const SAVE_DIR = "user://saves/"
const MAX_SLOTS = 3
const CHECKPOINT_PATH = SAVE_DIR + "checkpoint.save"


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

	return await _aplicar_dados_carregados(dados)


# Salva um checkpoint automático (posição, itens, vida, etc), separado dos
# slots manuais. Usado pelas bancadas ao interagir, e no respawn ao morrer.
func salvar_checkpoint(player) -> bool:
	if player == null or !is_instance_valid(player):
		return false

	if !player.has_method("obter_dados_save"):
		return false

	var dados: Dictionary = player.obter_dados_save()
	dados["data_hora"] = Time.get_datetime_string_from_system()

	var file = FileAccess.open(CHECKPOINT_PATH, FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(JSON.stringify(dados))
	file.close()

	return true


func existe_checkpoint() -> bool:
	return FileAccess.file_exists(CHECKPOINT_PATH)


func obter_dados_checkpoint() -> Dictionary:
	if !existe_checkpoint():
		return {}

	var file = FileAccess.open(CHECKPOINT_PATH, FileAccess.READ)

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


func carregar_checkpoint() -> bool:
	var dados = obter_dados_checkpoint()

	if dados.is_empty():
		return false

	return await _aplicar_dados_carregados(dados)


func _aplicar_dados_carregados(dados: Dictionary) -> bool:
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

##PARA PEGAR O ULTIMO SAVE É SO FAZER ISSO DAQ
##var ultimo := SaveManager.obter_ultimo_save()
	##if ultimo != -1:
			##await SaveManager.carregar_jogo(ultimo)

func obter_ultimo_save() -> int:
	# comeca sem nenhum save
	var slot_mais_recente := -1
	var data_mais_recente := ""

	# verifica todos os slots
	for slot in range(1, MAX_SLOTS + 1):
		var dados := obter_info_slot(slot)

		# pula se o slot estiver vazio
		if dados.is_empty():
			continue

		# pega a data do save
		var data = dados.get("data_hora", "")

		# ve se esse save e mais recente
		if data > data_mais_recente:
			data_mais_recente = data
			slot_mais_recente = slot

	# retorna o slot mais recente
	return slot_mais_recente
