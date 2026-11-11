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
    var color: Color = [Color("38d5ea"), Color("f1a353"), Color("ed5cb8")][clampi(variante, 0, 2)]
    var lum := 0.055 + maxf(destello * 1.5, 0.0)
    draw_circle(Vector2.ZERO, 24.0 + 1.4 * sin(tiempo * 2.0), Color(color.r, color.g, color.b, lum))
    draw_texture(TEXTURAS[clampi(variante, 0, 2)][frame], Vector2(-28, -28), tinte)
    if destello > 0.0:
        draw_arc(Vector2.ZERO, 26.0, 0.0, TAU, 28, Color("ffffff"), 2.0)
