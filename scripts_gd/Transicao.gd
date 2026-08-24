extends Node


const SHADER_TRANSICAO = preload("res://gdshader/transicao.gdshader")

var transicao_canvas: CanvasLayer
var transicao_rect: ColorRect
var transicao_material: ShaderMaterial

var trocando_cena := false

var voltando_da_zona_fogo := false
var voltando_da_sala_elemental := false

func iniciar_transicao() -> void:
	if transicao_canvas != null:
		return

	transicao_canvas = CanvasLayer.new()
	transicao_canvas.layer = 1000

	transicao_rect = ColorRect.new()
	transicao_rect.color = Color.BLACK
	transicao_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transicao_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	transicao_material = ShaderMaterial.new()
	transicao_material.shader = SHADER_TRANSICAO
	transicao_material.set_shader_parameter("height", -1.0)

	transicao_rect.material = transicao_material

	transicao_canvas.add_child(transicao_rect)
	get_tree().root.add_child(transicao_canvas)

func trocar_cena(caminho_cena: String, nome_entrada: String = "") -> void:
	if trocando_cena:
		return

	if caminho_cena == "":
		return

	var cena_atual = get_tree().current_scene

	if cena_atual != null:
		if cena_atual.scene_file_path == caminho_cena:
			return

	
	if cena_atual.scene_file_path == "res://zona_fogo.tscn" and caminho_cena == "res://cenas_tscn/zona_neutra.tscn":
		voltando_da_zona_fogo = true
	else:
		voltando_da_zona_fogo = false


	if cena_atual.scene_file_path == "res://cenas_tscn/salas/sala_porta_elemental.tscn" and caminho_cena == "res://zona_fogo.tscn":
		voltando_da_sala_elemental = true
	else:
		voltando_da_sala_elemental = false


	trocando_cena = true

	iniciar_transicao()

	var tween_saida := create_tween()

	tween_saida.tween_method(
		func(valor):
			if is_instance_valid(transicao_material):
				transicao_material.set_shader_parameter("height", valor),
		-1.0,
		1.0,
		0.7
	)

	await tween_saida.finished

	var jogador_antigo := get_tree().get_first_node_in_group("Player")
	var dados_jogador := {}

	if (
		jogador_antigo != null
		and is_instance_valid(jogador_antigo)
		and jogador_antigo.has_method("obter_dados_save")
	):
		dados_jogador = jogador_antigo.obter_dados_save()
	var erro := get_tree().change_scene_to_file(caminho_cena)

	if erro != OK:
		
		voltando_da_zona_fogo = false
		finalizar()
		return

	await get_tree().scene_changed

	var player = await esperar_player()

	if !dados_jogador.is_empty() and player.has_method("aplicar_dados_save"):
		player.aplicar_dados_save(dados_jogador)

	if nome_entrada != "":
		var entrada = procurar_no_por_nome(
			get_tree().current_scene,
			nome_entrada
		)

		if entrada != null:
			player.global_position = entrada.global_position
		else:
			print("marker nao encontrado: ", nome_entrada)

	var tween_entrada := create_tween()

	tween_entrada.tween_method(
		func(valor):
			if is_instance_valid(transicao_material):
				transicao_material.set_shader_parameter("height", valor),
		1.0,
		-1.0,
		0.7
	)

	await tween_entrada.finished

	finalizar()


func voltar_da_zona_fogo(caminho_cena: String, nome_entrada: String = "") -> void:


	voltando_da_zona_fogo = true

	trocar_cena(caminho_cena, nome_entrada)


func esperar_player():
	while true:
		var player = get_tree().get_first_node_in_group("Player")

		if player != null:
			return player

		await get_tree().process_frame


func procurar_no_por_nome(no: Node, nome: String) -> Node:
	if no.name == nome:
		return no

	for filho in no.get_children():
		var resultado = procurar_no_por_nome(filho, nome)

		if resultado != null:
			return resultado

	return null


func finalizar() -> void:
	if is_instance_valid(transicao_canvas):
		transicao_canvas.queue_free()

	transicao_canvas = null
	transicao_rect = null
	transicao_material = null

	trocando_cena = false
