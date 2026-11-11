extends Node2D
## Marca temporal de un disparo enemigo. No causa daño: es una alerta visual.
var origen: Vector2
var direccion: Vector2
var duracion := 0.70
var tiempo := 0.0
var color := Color("ff677d")

func configurar(punto: Vector2, vector: Vector2, segundos: float = 0.70, tinte: Color = Color("ff677d")) -> void:
    origen = punto
    direccion = vector.normalized()
    duracion = segundos
    tiempo = 0.0
    color = tinte
    queue_redraw()

func _process(delta: float) -> void:
    tiempo += delta
    queue_redraw()

func _draw() -> void:
    var pulso := 0.45 + absf(sin(tiempo * 15.0)) * 0.45
    var tinte := Color(color.r, color.g, color.b, pulso)
    # Segmentos en la trayectoria prevista; el jugador puede apartarse.
    for i in range(0, 8):
        var desde := origen + direccion * float(i * 58)
        var hasta := desde + direccion * 22.0
        draw_line(desde, hasta, tinte, 2.0)
    draw_arc(origen, 16.0 + sin(tiempo * 13.0) * 2.0, 0.0, TAU, 22, tinte, 2.0)
