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
    # Ambiente específico de cada capítulo, sin alterar colisiones.
    if escenario == 0:
        _luces_azoteas()
    elif escenario == 1:
        _chispas_forja()
    elif escenario == 2:
        _barrido_ciudadela()
    else:
        _nucleo_activo()

# Los eventos atmosféricos se dibujan encima de las texturas, pero fuera del
# área de lectura del HUD: sin añadir fuentes de daño ni comprometer FPS.


func _luces_azoteas() -> void:
    for i in range(16):
        var x := fposmod(float(i * 87 + 13) + tiempo * (7.0 + float(i % 3) * 4.0), 480.0)
        var y := fposmod(float(i * 49 + 61) + sin(tiempo * 0.7 + float(i)) * 12.0, 720.0)
        draw_circle(Vector2(x, y), 1.0 + float(i % 2), Color(0.16, 0.94, 0.95, 0.20))
    # Luces lejanas de helicópteros de vigilancia.
    var helic := Vector2(fposmod(tiempo * 17.0 + 65.0, 580.0) - 45.0, 220.0 + sin(tiempo * 0.6) * 16.0)
    draw_line(helic - Vector2(9, 0), helic + Vector2(9, 0), Color("174f6b"), 2)
    draw_circle(helic + Vector2(7, 0), 2.0, Color(1, 0.24, 0.44, 0.7))

func _chispas_forja() -> void:
    for i in range(26):
        var phase := float(i * 29)
        var x := fposmod(phase * 2.0 + sin(tiempo * 1.1 + phase) * 44.0 + tiempo * 19.0, 480.0)
        var y := fposmod(phase * 4.7 - tiempo * (22.0 + float(i % 4) * 13.0), 720.0)
        var col := Color(1.0, 0.42 + float(i % 3) * 0.1, 0.1, 0.23)
        draw_line(Vector2(x, y), Vector2(x - 1, y - 6), col, 1.0)
    draw_rect(Rect2(0, 550, 480, 170), Color(0.5, 0.12, 0.02, 0.025 + 0.018 * sin(tiempo * 2.0)))

func _barrido_ciudadela() -> void:
    for i in range(3):
        var x := fposmod(tiempo * 21.0 + float(i * 220), 550.0) - 35.0
        draw_rect(Rect2(x, 108, 8, 492), Color(0.72, 0.3, 0.95, 0.026))
        draw_line(Vector2(x, 108), Vector2(x, 598), Color(0.9, 0.4, 1.0, 0.07), 1.0)

func _nucleo_activo() -> void:
    var pulso_nucleo := 0.5 + 0.5 * sin(tiempo * 1.35)
    var centro := Vector2(240, 258)
    for r in range(3):
        draw_arc(centro, 75.0 + float(r) * 38.0 + pulso_nucleo * 7.0, 0, TAU, 70, Color(1.0, 0.13, 0.35, 0.05 - float(r) * 0.009), 1.4)
    for i in range(15):
        var theta := tiempo * 0.3 + float(i) * TAU / 15.0
        var r := 92.0 + float(i % 3) * 35.0
        var pos := centro + Vector2(cos(theta), sin(theta)) * r
        draw_circle(pos, 1.0 + float(i % 2), Color(1.0, 0.26, 0.39, 0.12))
