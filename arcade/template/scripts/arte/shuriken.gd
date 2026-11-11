extends Node2D
const TEXTURA := preload("res://recursos/shuriken.png")
var tiempo := 0.0
func _process(delta: float) -> void:
	tiempo += delta
	rotation += delta * 14.0
	queue_redraw()
func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color(0.25, 1, 0.98, 0.11))
	draw_texture(TEXTURA, Vector2(-14, -14))
