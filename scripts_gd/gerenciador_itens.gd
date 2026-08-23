extends Node

## Guarda em memória (RAM) quais itens colecionáveis do mundo (medalhões,
## amuletos, etc -- qualquer item_coletavel.gd) já foram pegos nesta sessão.
## Serve pra impedir que o objeto reapareça na sala quando o jogador sai e
## entra de novo (troca de cena), já que cada sala recria seus nós do zero.
##
## Segue exatamente o mesmo padrão do GerenciadorChefes: o SaveManager lê
## obter_lista_coletados() na hora de salvar (jogo ou checkpoint) e chama
## carregar_lista() na hora de carregar, mantendo os itens do mundo sempre
## sincronizados com o inventário do jogador. Isso é essencial: se o item
## sumir do chão mas não estiver garantido no inventário salvo, o jogador
## fica sem os dois -- o mesmo tipo de soft lock que já corrigimos pros
## chefes.
##
## Uso, dentro do item_coletavel.gd:
##   if GerenciadorItens.foi_coletado(item_id):
##       queue_free()
##       return
##
##   func coletar():
##       ...
##       GerenciadorItens.marcar_coletado(item_id)

var _itens_coletados := {}


func marcar_coletado(item_id: String) -> void:
	if item_id == "":
		return

	_itens_coletados[item_id] = true


func foi_coletado(item_id: String) -> bool:
	return _itens_coletados.get(item_id, false)


## Chamado pelo SaveManager ao carregar/começar um jogo, pra não misturar
## o progresso de uma sessão/save com outro.
func resetar() -> void:
	_itens_coletados.clear()


## Devolve a lista de ids de itens coletados, pra ser gravada no save/checkpoint
## junto com o resto do progresso do jogador.
func obter_lista_coletados() -> Array:
	return _itens_coletados.keys()


## Restaura o estado dos itens coletados a partir de uma lista salva.
## Sempre reseta antes de aplicar, pra garantir que o estado dos itens do
## mundo fique exatamente igual ao daquele save/checkpoint.
func carregar_lista(lista: Array) -> void:
	resetar()

	for item_id in lista:
		marcar_coletado(String(item_id))
