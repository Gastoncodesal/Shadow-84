extends Node2D
const CUADROS := [
	[preload("res://recursos/raiden_0_0.png"), preload("res://recursos/raiden_0_1.png")],
	[preload("res://recursos/raiden_1_0.png"), preload("res://recursos/raiden_1_1.png")],
	[preload("res://recursos/raiden_2_0.png"), preload("res://recursos/raiden_2_1.png")]
]
var fase_visual: int = 0
var tiempo := 0.0
var destello := 0.0
func _process(delta: float) -> void:
	tiempo += delta
	destello = maxf(0.0, destello - delta)
	queue_redraw()
func _draw() -> void:
	var f: int = int(tiempo * 3.5) % 2
	var color: Color = Color(1, 0.45, 0.45) if destello > 0 else Color.WHITE
	var pulso: float = (sin(tiempo * 5.0) + 1.0) * 0.5
	draw_circle(Vector2(0, 18), 76 + pulso * 4, Color(1, 0.15, 0.35, 0.045))
	draw_texture(CUADROS[clampi(fase_visual, 0, 2)][f], Vector2(-82, -71), color)
