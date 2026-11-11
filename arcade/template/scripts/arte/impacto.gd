extends Node2D
## Estallido liviano de 12 fragmentos: se autodestruye tras 0,45 segundos.
var color_efecto := Color("4ef8f0")
var tiempo := 0.0
var vida := 0.45
var escala_efecto := 1.0
func configurar(posicion: Vector2, color_nuevo: Color, tamano: float = 1.0) -> void:
	position = posicion
	color_efecto = color_nuevo
	escala_efecto = tamano
func _process(delta: float) -> void:
	tiempo += delta
	if tiempo >= vida:
		queue_free()
	else:
		queue_redraw()
func _draw() -> void:
	var pro: float = tiempo / vida
	var col: Color = color_efecto
	col.a = (1.0 - pro) * 0.85
	for i in range(12):
		var a: float = TAU * float(i) / 12.0
		var interior: Vector2 = Vector2.RIGHT.rotated(a) * (4.0 + pro * 13.0) * escala_efecto
		var exterior: Vector2 = Vector2.RIGHT.rotated(a) * (9.0 + pro * 28.0) * escala_efecto
		draw_line(interior, exterior, col, 2.0 * escala_efecto)
	draw_circle(Vector2.ZERO, (1.0 - pro) * 8.0 * escala_efecto, Color(col.r, col.g, col.b, (1.0 - pro) * 0.28))
