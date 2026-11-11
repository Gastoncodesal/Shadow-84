extends Node2D
const TEXTURAS := [
	preload("res://recursos/proyectil_rojo.png"),
	preload("res://recursos/proyectil_dorado.png"),
	preload("res://recursos/proyectil_azul.png")
]
var tipo := 0
var tiempo := 0.0
func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
func _draw() -> void:
	draw_texture(TEXTURAS[clampi(tipo, 0, 2)], Vector2(-12, -12))
	draw_circle(Vector2.ZERO, 13.0 + sin(tiempo * 9.0) * 2.0, Color(1, 0.24, 0.28, 0.06))
