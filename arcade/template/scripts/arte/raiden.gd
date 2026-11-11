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
    var aura: Color = [Color("eb668d"), Color("f276a5"), Color("ffb64b")][clampi(fase_visual, 0, 2)]
    for anillo in range(3):
        var radio := 68.0 + float(anillo) * 15.0 + sin(tiempo * 2.0 - float(anillo)) * 3.0
        draw_arc(Vector2(0, -4), radio, fposmod(tiempo * (0.3 + float(anillo) * 0.18), TAU), fposmod(tiempo * (0.3 + float(anillo) * 0.18), TAU) + PI, 32, Color(aura.r, aura.g, aura.b, 0.10), 2.0)
    draw_texture(CUADROS[clampi(fase_visual, 0, 2)][f], Vector2(-82, -71), color)
