extends Enemy
class_name Totem_alavanca


signal reacao_ativada(reacao: Reacao)


enum Reacao {
	NENHUMA,
	VAPORIZACAO,
	ELETRICAMENTE_CARREGADO,
	ENRAIZAMENTO,
	QUEIMADURA,
	SOBRECARGA,
	ELETRIZACAO
}


@export var reacao_especifica: Reacao = Reacao.NENHUMA
@export var ativa := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	Speed = 0
	Life = 999999

	atualizar_icones_elementais()

	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")


func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)


func receber_dano_corrente(_dano: int) -> void:
	return


func die() -> void:
	return


func _dano(_dano: int, _origem_x: float) -> void:
	return


func receberAtaque(tipo) -> void:
	if ativa:
		return

	if tipo not in tiposVariados:
		return

	if elementosRecebidos.size() == 0:
		elementosRecebidos.append(tipo)

		atualizar_icones_elementais()
		tocar_animacao_elemento(tipo)

		return

	if elementosRecebidos[0] == tipo:
		return

	if elementosRecebidos.size() == 1:
		elementosRecebidos.append(tipo)

		atualizar_icones_elementais()
		ativar_reacao(0, global_position.x)


func _aplicar_elemento(elemento, _dano: int = 0, _origem_x: float = 0.0) -> int:
	if ativa:
		return 0

	var tipo := ""

	match elemento:
		0:
			tipo = fogo
		1:
			tipo = agua
		2:
			tipo = raio
		3:
			tipo = planta
		_:
			return 0

	receberAtaque(tipo)

	return 0


func ativar_reacao(_dano: int, _origem_x: float) -> int:
	if ativa:
		return 0

	if elementosRecebidos.size() < 2:
		return 0

	var elemento_1 = elementosRecebidos[0]
	var elemento_2 = elementosRecebidos[1]

	var elementos = [
		elemento_1,
		elemento_2
	]

	var reacao := Reacao.NENHUMA

	if fogo in elementos and agua in elementos:
		reacao = Reacao.VAPORIZACAO
	elif agua in elementos and raio in elementos:
		reacao = Reacao.ELETRICAMENTE_CARREGADO
	elif agua in elementos and planta in elementos:
		reacao = Reacao.ENRAIZAMENTO
	elif fogo in elementos and planta in elementos:
		reacao = Reacao.QUEIMADURA
	elif fogo in elementos and raio in elementos:
		reacao = Reacao.SOBRECARGA
	elif raio in elementos and planta in elementos:
		reacao = Reacao.ELETRIZACAO

	if reacao == Reacao.NENHUMA:
		elementosRecebidos.clear()
		atualizar_icones_elementais()
		return 0

	ativa = true

	elementosRecebidos.clear()
	atualizar_icones_elementais()

	tocar_animacao_reacao(reacao)

	if reacao == reacao_especifica:
		reacao_ativada.emit(reacao)

	return 0


func tocar_animacao_elemento(tipo: String) -> void:
	var nome_animacao := obter_nome_animacao_elemento(tipo)

	if nome_animacao == "":
		return

	if not animated_sprite.sprite_frames.has_animation(nome_animacao):
		return

	animated_sprite.sprite_frames.set_animation_loop(nome_animacao, true)
	animated_sprite.play(nome_animacao)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", position.x + 1, 0.05)
	tween.tween_property(self, "position:x", position.x - 1, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)


func tocar_animacao_reacao(reacao: Reacao) -> void:
	var nome_animacao := obter_nome_animacao_reacao(reacao)

	if nome_animacao == "":
		return

	if not animated_sprite.sprite_frames.has_animation(nome_animacao):
		return

	animated_sprite.sprite_frames.set_animation_loop(nome_animacao, false)
	animated_sprite.play(nome_animacao)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", position.x + 1, 0.05)
	tween.tween_property(self, "position:x", position.x - 1, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)


func obter_nome_animacao_elemento(tipo: String) -> String:
	match tipo:
		fogo:
			return "fogo"
		agua:
			return "agua"
		raio:
			return "raio"
		planta:
			return "planta"

	return ""


func obter_nome_animacao_reacao(reacao: Reacao) -> String:
	match reacao:
		Reacao.VAPORIZACAO:
			return "vaporizacao"
		Reacao.ELETRICAMENTE_CARREGADO:
			return "eletricamente_carregado"
		Reacao.ENRAIZAMENTO:
			return "enraizamento"
		Reacao.QUEIMADURA:
			return "queimadura"
		Reacao.SOBRECARGA:
			return "sobrecarga"
		Reacao.ELETRIZACAO:
			return "eletrizacao"

	return ""
