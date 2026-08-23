extends Node


var _chefes_derrotados := {}


func marcar_derrotado(id_chefe: String) -> void:
	_chefes_derrotados[id_chefe] = true


func foi_derrotado(id_chefe: String) -> bool:
	return _chefes_derrotados.get(id_chefe, false)

func resetar() -> void:
	_chefes_derrotados.clear()


func obter_lista_derrotados() -> Array:
	return _chefes_derrotados.keys()


func carregar_lista(lista: Array) -> void:
	resetar()

	for id_chefe in lista:
		marcar_derrotado(String(id_chefe))
