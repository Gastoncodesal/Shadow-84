extends Node2D
## Tres siluetas de enemigos con alternancia de cuadros, golpe y brillo.
const TEXTURAS := [
	[preload("res://recursos/centinela_0_0.png"), preload("res://recursos/centinela_0_1.png")],
	[preload("res://recursos/centinela_1_0.png"), preload("res://recursos/centinela_1_1.png")],
	[preload("res://recursos/centinela_2_0.png"), preload("res://recursos/centinela_2_1.png")]
]
var variante: int = 0
var tiempo := 0.0
var destello := 0.0

func _process(delta: float) -> void:
	tiempo += delta
	destello = maxf(destello - delta, 0.0)
	queue_redraw()

func _draw() -> void:
	var frame: int = int(tiempo * 3.5) % 2
	var tinte: Color = Color(1.0, 0.75, 0.8) if destello > 0.0 else Color.WHITE
	draw_texture(TEXTURAS[clampi(variante, 0, 2)][frame], Vector2(-28, -28), tinte)
