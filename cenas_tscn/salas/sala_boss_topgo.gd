extends Node2D

@onready var boss: TopgoBoss = $TopgoBoss
@onready var gatilho: Area2D = $GatilhoLuta
@onready var hud_chefe: CanvasLayer = $HudChefe
@onready var barra_vida_chefe: TextureProgressBar = $HudChefe/Interface/BarraVidaChefe
@onready var nome_chefe: Label = $HudChefe/Interface/NomeChefe
@onready var plataforma_fase2: StaticBody2D = $PlataformaFase2
@onready var soundtrack: AudioStreamPlayer = $soundtrack


const ID_CHEFE := "topgo"

var luta_iniciada := false

#var italo: Guimaraes 

var pedacos_arena_fase3: Array[ColorRect] = []


func _ready() -> void:
	hud_chefe.visible = false

	if boss:
		boss.chefe_derrotado.connect(_on_chefe_derrotado)
		boss.fase_um_concluida.connect(_on_fase_um_concluida)
		boss.fase_dois_concluida.connect(_on_fase_dois_concluida)
		boss.zona_fogo_escolhida.connect(_on_zona_fogo_escolhida)

	if GerenciadorChefes.foi_derrotado(ID_CHEFE):
		_configurar_sala_com_chefe_ja_morto()


func _process(_delta: float) -> void:
	if not luta_iniciada:
		return

	if not is_instance_valid(boss):
		return

	barra_vida_chefe.max_value = boss.vida_maxima_boss
	barra_vida_chefe.value = max(boss.Life, 0)


func _on_gatilho_luta_body_entered(body: Node2D) -> void:
	if luta_iniciada:
		return

	if not body.is_in_group("Player"):
		return

	
	luta_iniciada = true
	hud_chefe.visible = true

	if boss:
		boss.iniciar_luta()
		soundtrack.play()


func _on_chefe_derrotado() -> void:
	nome_chefe.text = "TOPGO DERROTADO"

	GerenciadorChefes.marcar_derrotado(ID_CHEFE)
	_apagar_musica_chefe()
	_abrir_passagem()

	await get_tree().create_timer(4.0).timeout

	if is_instance_valid(hud_chefe):
		hud_chefe.visible = false


func _configurar_sala_com_chefe_ja_morto() -> void:
	if is_instance_valid(boss):
		boss.dead = true
		boss.visible = false
		boss.set_physics_process(false)
		boss.set_collision_layer_value(1, false)
		boss.set_collision_mask_value(1, false)

	if is_instance_valid(gatilho):
		gatilho.monitoring = false

	_abrir_passagem(true)


func _apagar_musica_chefe() -> void:
	if not is_instance_valid(soundtrack) or not soundtrack.playing:
		return

	var tween := create_tween()
	tween.tween_property(soundtrack, "volume_db", -40.0, 2.0)
	tween.tween_callback(soundtrack.stop)


func _abrir_passagem(instantaneo: bool = false) -> void:
	var passagem := get_node_or_null("PassagemLateral")

	if passagem and passagem.has_method("abrir"):
		passagem.abrir(instantaneo)


func _on_fase_um_concluida() -> void:
	nome_chefe.text = "TOPGO — FASE 2"
	_transformar_arena_fase_dois()


func _on_fase_dois_concluida() -> void:
	nome_chefe.text = "TOPGO — FASE FINAL"
	_transformar_arena_fase_tres()


func _transformar_arena_fase_dois() -> void:
	if not is_instance_valid(plataforma_fase2):
		return

	_tremer_camera(3.0, 0.5)

	var colisao: CollisionShape2D = plataforma_fase2.get_node("CollisionShape2D")
	if colisao:
		colisao.disabled = false

	var y_final := plataforma_fase2.position.y

	plataforma_fase2.visible = true
	plataforma_fase2.modulate.a = 0.0
	plataforma_fase2.position.y = y_final - 14.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(plataforma_fase2, "modulate:a", 1.0, 0.5)
	tween.tween_property(
		plataforma_fase2, "position:y", y_final, 0.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _transformar_arena_fase_tres() -> void:
	if not is_instance_valid(boss):
		return

	for parede in [$ParedeEsquerda, $ParedeDireita, $PassagemLateral]:
		if is_instance_valid(parede):
			var tween := create_tween()
			tween.tween_property(parede, "modulate", Color(1.0, 0.55, 0.45), 0.6)

	_tremer_camera(6.0, 0.7)
	_criar_pedacos_arena_fase3()


func _criar_pedacos_arena_fase3() -> void:
	var largura_total := boss.limite_direito - boss.limite_esquerdo
	var y_chao := boss.posicao_base.y + boss.altura_chao
	var altura_pedaco := 16.0
	var fresta := 7.0

	pedacos_arena_fase3.clear()

	var pedacos := Node2D.new()
	pedacos.name = "PedacosArenaFase3"
	pedacos.z_index = -1
	add_child(pedacos)

	var x := boss.limite_esquerdo

	for i in range(TopgoBoss.PROPORCOES_ZONAS_FASE3.size()):
		var largura_zona: float = largura_total * TopgoBoss.PROPORCOES_ZONAS_FASE3[i]

		var pedaco := ColorRect.new()
		pedaco.color = Color(0.35, 0.33, 0.37)
		pedaco.size = Vector2(max(largura_zona - fresta, 4.0), altura_pedaco)
		pedaco.pivot_offset = pedaco.size / 2.0
		pedaco.position = Vector2(x + fresta / 2.0, y_chao)
		pedacos.add_child(pedaco)
		pedacos_arena_fase3.append(pedaco)

		var y_original := pedaco.position.y
		var queda := randf_range(2.0, 9.0)
		var rotacao := deg_to_rad(randf_range(-3.0, 3.0))
		var atraso := i * 0.05

		pedaco.position.y -= 24.0
		pedaco.modulate.a = 0.0

		var tween := create_tween()
		tween.tween_interval(atraso)
		tween.set_parallel(true)
		tween.tween_property(pedaco, "modulate:a", 1.0, 0.25)
		tween.tween_property(
			pedaco, "position:y", y_original + queda, 0.35
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(pedaco, "rotation", rotacao, 0.35)

		x += largura_zona



func _on_zona_fogo_escolhida(indice: int) -> void:
	if indice < 0 or indice >= pedacos_arena_fase3.size():
		return

	var pedaco: ColorRect = pedacos_arena_fase3[indice]

	if not is_instance_valid(pedaco):
		return

	var cor_normal := pedaco.color
	var cor_aviso := Color(1.0, 0.4, 0.2)
	var duracao: float = boss.tempo_aviso_fogo_zona if is_instance_valid(boss) else 0.45
	var ciclos: int = max(2, int(ceil(duracao / 0.3)))

	var tween := create_tween()
	tween.set_loops(ciclos)
	tween.tween_property(pedaco, "color", cor_aviso, 0.15)
	tween.tween_property(pedaco, "color", cor_normal, 0.15)


func _tremer_camera(intensidade: float, duracao: float) -> void:
	if not is_instance_valid(boss):
		return

	var jogador: Node2D = boss.jogador

	if jogador and is_instance_valid(jogador) and jogador.has_method("tremer_camera"):
		jogador.tremer_camera(intensidade, duracao)
