extends Node

const SAVE_DIR = "user://saves/"
const MAX_SLOTS = 3
const CHECKPOINT_PATH = SAVE_DIR + "checkpoint.save"

# Cena onde todo novo jogo sempre começa.
const CENA_INICIAL := "res://cenas_tscn/tutorial.tscn"


const MAGIAS_INICIAIS := [0, 4, 8, 12]


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
	dados["chefes_derrotados"] = GerenciadorChefes.obter_lista_derrotados()
	dados["itens_coletados_mundo"] = GerenciadorItens.obter_lista_coletados()

	var file = FileAccess.open(_caminho_slot(slot), FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(JSON.stringify(dados))
	file.close()

	return true


func _dados_novo_jogo() -> Dictionary:
	return {
		"vida": 10,
		"vida_max": 10,
		"mana": 100,
		"mana_max": 100,
		"almas_agua": 0,
		"almas_fogo": 0,
		"almas_raio": 0,
		"almas_planta": 0,
		"magias_desbloqueadas": MAGIAS_INICIAIS.duplicate(),
		"magias_equipadas": MAGIAS_INICIAIS.duplicate(),
		"itens": [],
		"itens_vistos": [],
		"medalhao_ativo": -1,
		"chefes_derrotados": [],
		"itens_coletados_mundo": [],
		"data_hora": Time.get_datetime_string_from_system(),
		"checkpoint_cena": CENA_INICIAL
	}

func novo_jogo(slot: int) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		return false

	var dados := _dados_novo_jogo()

	var file = FileAccess.open(_caminho_slot(slot), FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(JSON.stringify(dados))
	file.close()

	return await _aplicar_dados_carregados(dados)


func carregar_jogo(slot: int) -> bool:
	if !slot_existe(slot):
		return false

	var dados = obter_info_slot(slot)

	if dados.is_empty():
		return false

	return await _aplicar_dados_carregados(dados)


func salvar_checkpoint(player) -> bool:
	if player == null or !is_instance_valid(player):
		return false

	if !player.has_method("obter_dados_save"):
		return false

	var dados: Dictionary = player.obter_dados_save()
	dados["data_hora"] = Time.get_datetime_string_from_system()
	dados["chefes_derrotados"] = GerenciadorChefes.obter_lista_derrotados()
	dados["itens_coletados_mundo"] = GerenciadorItens.obter_lista_coletados()

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
	# Precisa acontecer ANTES da troca de cena: se a cena de destino for a sala
	# de algum chefe, o _ready() dela já confere GerenciadorChefes.foi_derrotado()
	# pra decidir se o chefe reaparece ou não. Se atualizássemos isso depois da
	# troca de cena, a sala leria o estado antigo (de antes do checkpoint) e o
	# chefe podia continuar marcado como morto por engano.
	GerenciadorChefes.carregar_lista(dados.get("chefes_derrotados", []))

	# mesmo motivo: se a sala de destino tiver um medalhão/amuleto, o
	# item_coletavel.gd dela confere GerenciadorItens.foi_coletado() no
	# _ready() pra decidir se ainda aparece no chão ou não.
	GerenciadorItens.carregar_lista(dados.get("itens_coletados_mundo", []))

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
