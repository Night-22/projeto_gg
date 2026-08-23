extends Node

var _itens_coletados := {}


func marcar_coletado(item_id: String) -> void:
	if item_id == "":
		return

	_itens_coletados[item_id] = true


func foi_coletado(item_id: String) -> bool:
	return _itens_coletados.get(item_id, false)


func resetar() -> void:
	_itens_coletados.clear()


func obter_lista_coletados() -> Array:
	return _itens_coletados.keys()


func carregar_lista(lista: Array) -> void:
	resetar()

	for item_id in lista:
		marcar_coletado(String(item_id))
