extends Node2D
## Ren: seis cuadros, respiración, dirección de la cinta, pose de ataque.
const CUADROS := [
    preload("res://recursos/ren_0.png"), preload("res://recursos/ren_1.png"),
    preload("res://recursos/ren_2.png"), preload("res://recursos/ren_3.png"),
    preload("res://recursos/ren_4.png"), preload("res://recursos/ren_5.png")
]
var tiempo := 0.0
var golpe := 0.0
var destello_dash := 0.0
var direccion_dash := 1.0

func _process(delta: float) -> void:
    tiempo += delta
    golpe = maxf(0.0, golpe - delta)
    destello_dash = maxf(0.0, destello_dash - delta)
    queue_redraw()

func atacar() -> void:
    golpe = 0.22

func esquivar(direccion: float) -> void:
    destello_dash = 0.38
    direccion_dash = direccion

func _draw() -> void:
    var cuadro: int = (4 + int(tiempo * 18.0) % 2) if golpe > 0 else int(tiempo * 5.0) % 4
    var textura: Texture2D = CUADROS[cuadro]
    var lateral := 0.0
    var cuerpo := get_parent() as CharacterBody2D
    if cuerpo != null:
        lateral = cuerpo.velocity.x / 300.0 * 3.0
    if destello_dash > 0.0:
        var a := destello_dash / 0.38
        draw_texture(textura, Vector2(-36.0 - direccion_dash * 56.0, -46.0), Color(0.25, 1.0, 1.0, 0.18 * a))
        draw_texture(textura, Vector2(-36.0 - direccion_dash * 27.0, -46.0), Color(0.48, 0.89, 1.0, 0.33 * a))
        draw_arc(Vector2.ZERO, 29.0, 0.0, TAU, 30, Color(0.1, 0.96, 0.9, a * 0.26), 2.0)
    draw_texture(textura, Vector2(-36.0 + lateral, -46.0))
    if golpe > 0.0:
        draw_line(Vector2(0, -28), Vector2(0, -52), Color(0.58, 1.0, 1.0, golpe * 2.0), 3.0)
    # Brillo de piso para separar la silueta del escenario.
    draw_arc(Vector2(0, 28), 18, 0, PI, 20, Color(0.16, 0.9, 0.9, 0.26), 2.0)
