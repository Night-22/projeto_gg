extends Enemy
class_name Totem


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

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	Speed = 0
	Life = 999

	atualizar_icones_elementais()

func die() -> void:
	return

func _physics_process(delta: float) -> void:
	if dead:
		return

	processar_reacoes(delta)


func receberAtaque(tipo):
	if tipo not in tiposVariados:
		return

	if elementosRecebidos.size() >= 1:
		return

	elementosRecebidos.append(tipo)

	atualizar_icones_elementais()

	tocar_animacao_elemento(tipo)


func ativar_reacao(_dano, _origem_x: float) -> int:
	var elemento_1 = elementosRecebidos[0]
	var elemento_2 = elementosRecebidos[1]

	var elementos = [
		elemento_1,
		elemento_2
	]

	var elemento_anterior = elemento_1


	elementosRecebidos.clear()
	atualizar_icones_elementais()


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


	# O totem não causa dano.
	# Primeiro toca a animação do elemento anterior.
	# Depois toca a animação da reação.
	if reacao != Reacao.NENHUMA:
		tocar_sequencia_reacao(elemento_anterior, reacao)

		if reacao == reacao_especifica:
			reacao_ativada.emit(reacao)


	return 0


func tocar_animacao_elemento(tipo: String) -> void:
	match tipo:
		fogo:
			if animated_sprite.sprite_frames.has_animation("fogo"):
				animated_sprite.play("fogo")

		agua:
			if animated_sprite.sprite_frames.has_animation("agua"):
				animated_sprite.play("agua")

		raio:
			if animated_sprite.sprite_frames.has_animation("raio"):
				animated_sprite.play("raio")

		planta:
			if animated_sprite.sprite_frames.has_animation("planta"):
				animated_sprite.play("planta")


func tocar_sequencia_reacao(elemento_anterior: String, reacao: Reacao) -> void:
	var nome_elemento := obter_nome_animacao_elemento(elemento_anterior)
	var nome_reacao := obter_nome_animacao_reacao(reacao)


	if nome_elemento == "" or nome_reacao == "":
		return


	# Toca primeiro o elemento que estava no totem.
	if animated_sprite.sprite_frames.has_animation(nome_elemento):
		animated_sprite.play(nome_elemento)

		await animated_sprite.animation_finished


	# Depois toca a reação elemental.
	if animated_sprite.sprite_frames.has_animation(nome_reacao):
		animated_sprite.play(nome_reacao)

		await animated_sprite.animation_finished


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
