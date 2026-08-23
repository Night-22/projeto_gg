extends StaticBody2D
class_name PassagemLateral

## Parede que bloqueia a passagem lateral da sala do chefe até ele ser derrotado.
##
## COMO USAR (no editor):
## 1. Crie um StaticBody2D na lateral da sala (onde vai ficar a passagem),
##    com um Sprite2D e um CollisionShape2D como filhos -- igual às paredes
##    que já existem em sala_boss_aranha.tscn / sala_boss_topgo.tscn.
##    Anexe este script a ele e dê um nome, ex: "PassagemLateral".
## 2. Do outro lado dessa parede, crie uma Area2D com o script
##    res://scripts_gd/transicao_cena.gd (igual à Area2D "transicao_cena"
##    que já existe em cada sala), apontando pro "cena_destino" da sala do
##    medalhão. Deixe o "monitoring" dela DESLIGADO no editor -- este script
##    liga sozinho quando a passagem abre.
## 3. No Inspector da PassagemLateral, aponte "area_transicao_path" pra essa Area2D.
## 4. No script da sala (sala_boss_x.gd), chame abrir() quando o chefe morrer
##    (isso já está pronto nas salas existentes, ver _abrir_passagem()).

@export var area_transicao_path: NodePath

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var colisao: CollisionShape2D = get_node_or_null("CollisionShape2D")

var aberta := false


## instantaneo = true quando a sala já carrega com o chefe derrotado
## (sem tocar animação, sem som -- estado já "resolvido").
func abrir(instantaneo: bool = false) -> void:
	if aberta:
		return

	aberta = true

	if colisao:
		colisao.set_deferred("disabled", true)

	var area_transicao := get_node_or_null(area_transicao_path)
	if area_transicao:
		area_transicao.monitoring = true

	if instantaneo:
		visible = false
		modulate.a = 0.0
		return

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): visible = false)
