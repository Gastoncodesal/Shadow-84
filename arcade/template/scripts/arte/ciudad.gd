extends Node2D
## Fondos artesanales por capítulo con lluvia, bruma y transiciones suaves.
const TEXTURAS := [
	preload("res://recursos/escenario_1.png"),
	preload("res://recursos/escenario_2.png"),
	preload("res://recursos/escenario_3.png"),
	preload("res://recursos/escenario_4.png")
]
const ACENTOS := [
	Color("29e6ed"), Color("f6aa68"), Color("e16bdf"), Color("f35e73")
]
var escenario: int = 0
var previo: int = 0
var transicion: float = 1.0
var tiempo: float = 0.0
var gotas: Array[Vector2] = []

func _ready() -> void:
	z_index = -15
	var aleatorio := RandomNumberGenerator.new()
	aleatorio.seed = 2084
	for i in range(75):
		gotas.append(Vector2(aleatorio.randf_range(0.0, 480.0), aleatorio.randf_range(0.0, 720.0)))

func cambiar_escenario(nuevo: int) -> void:
	nuevo = clampi(nuevo, 0, TEXTURAS.size() - 1)
	if nuevo == escenario:
		return
	previo = escenario
	escenario = nuevo
	transicion = 0.0

func _process(delta: float) -> void:
	tiempo += delta
	transicion = minf(1.0, transicion + delta * 0.48)
	queue_redraw()

func _draw() -> void:
	draw_texture(TEXTURAS[previo], Vector2.ZERO, Color(1, 1, 1, 1.0 - transicion))
	draw_texture(TEXTURAS[escenario], Vector2.ZERO, Color(1, 1, 1, transicion))
	var luz: Color = ACENTOS[escenario]
	# Capa climática: partículas con velocidades distintas según profundidad.
	for i in range(gotas.size()):
		var origen: Vector2 = gotas[i]
		var velocidad: float = 130.0 + float(i % 4) * 45.0
		var x: float = fposmod(origen.x - tiempo * (8.0 + float(i % 3) * 4.0), 480.0)
		var y: float = fposmod(origen.y + tiempo * velocidad, 720.0)
		var alpha: float = 0.14 if i % 3 != 0 else 0.29
		draw_line(Vector2(x, y), Vector2(x - 2, y + 9 + float(i % 4) * 2), Color(luz.r, luz.g, luz.b, alpha), 1.0)
	# Iluminación ambiental breve, evita fondos estáticos.
	var pulso: float = (sin(tiempo * 0.9) + 1.0) * 0.015
	draw_rect(Rect2(0, 0, 480, 720), Color(luz.r, luz.g, luz.b, pulso))
