extends Node

## Guarda em memória (RAM) quais chefes já foram derrotados na sessão atual.
## Serve pra impedir que o chefe volte quando o jogador sai e entra de novo
## na sala (troca de cena) dentro da mesma sessão de jogo.
##
## Esse estado sozinho não é gravado em disco automaticamente -- é o
## SaveManager quem lê obter_lista_derrotados() na hora de salvar (jogo ou
## checkpoint) e chama carregar_lista() na hora de carregar, guardando o
## progresso dos chefes JUNTO com o resto (itens, medalhão, etc). Isso é
## essencial: se o chefe derrotado e o item que ele soltou não andarem
## sincronizados, dá pra ficar numa situação sem chefe e sem item nenhum.
##
## Uso, dentro do script da sala do chefe:
##   if GerenciadorChefes.foi_derrotado("raio"):
##       ... coloca a sala no estado de "chefe já morto" ...
##
##   func _on_chefe_derrotado():
##       GerenciadorChefes.marcar_derrotado("raio")

var _chefes_derrotados := {}


func marcar_derrotado(id_chefe: String) -> void:
	_chefes_derrotados[id_chefe] = true


func foi_derrotado(id_chefe: String) -> bool:
	return _chefes_derrotados.get(id_chefe, false)


## Chamado automaticamente pelo SaveManager ao carregar/começar um jogo,
## pra não misturar o progresso de uma sessão/save com outro.
func resetar() -> void:
	_chefes_derrotados.clear()


## Devolve a lista de ids de chefes derrotados, pra ser gravada no save/checkpoint
## junto com o resto do progresso do jogador (itens, medalhão, etc).
func obter_lista_derrotados() -> Array:
	return _chefes_derrotados.keys()


## Restaura o estado dos chefes derrotados a partir de uma lista salva.
## Sempre reseta antes de aplicar, pra garantir que o estado dos chefes fique
## exatamente igual ao daquele save/checkpoint -- nunca "misturado" com o que
## tinha acontecido na sessão atual antes de carregar.
##
## É isso que evita o soft lock de: matar o chefe, coletar o medalhão, sair
## da sala e morrer sem salvar -- o checkpoint carregado desfaz o medalhão
## (porque não estava salvo), então agora ele também precisa desfazer o
## chefe derrotado, senão o jogador fica sem o item e sem poder pegá-lo de novo.
func carregar_lista(lista: Array) -> void:
	resetar()

	for id_chefe in lista:
		marcar_derrotado(String(id_chefe))
