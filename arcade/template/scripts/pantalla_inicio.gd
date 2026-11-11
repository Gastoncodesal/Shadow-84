extends CanvasLayer
## Portada interactiva; no modifica las tres oleadas ni el grafo narrativo.
signal comenzar
var _inicio: Button
var _destello: ColorRect
var _tiempo := 0.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 7
    _dibujar_portada()

func _panel(color: Color, borde: Color, radio: int = 3) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = borde
    s.set_border_width_all(1)
    s.set_corner_radius_all(radio)
    return s

func _etiqueta(texto: String, pos: Vector2, tam: Vector2, fuente: int, color: Color, centro: bool = false) -> Label:
    var l := Label.new()
    l.text = texto
    l.position = pos
    l.size = tam
    l.add_theme_font_size_override("font_size", fuente)
    l.add_theme_color_override("font_color", color)
    l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    if centro:
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(l)
    return l

func _dibujar_portada() -> void:
    var velo := ColorRect.new()
    velo.color = Color(0.006, 0.010, 0.026, 0.73)
    velo.size = Vector2(480, 720)
    velo.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(velo)
    var borde := PanelContainer.new()
    borde.position = Vector2(24, 51)
    borde.size = Vector2(432, 605)
    borde.add_theme_stylebox_override("panel", _panel(Color(0.02, 0.033, 0.073, 0.91), Color("3ce3e8")))
    add_child(borde)
    _etiqueta("NEO-KYOTO  //  2084", Vector2(37, 69), Vector2(400, 30), 15, Color("5be7ec"), true)
    _etiqueta("SHADOW", Vector2(47, 111), Vector2(386, 67), 51, Color("ecf9ff"), true)
    _etiqueta("// 84", Vector2(46, 174), Vector2(388, 57), 48, Color("ff5d93"), true)
    _etiqueta("LA ÚLTIMA SOMBRA", Vector2(48, 232), Vector2(384, 30), 17, Color("7cdbf3"), true)
    var retrato := TextureRect.new()
    retrato.texture = preload("res://recursos/portrait_ren.png")
    retrato.position = Vector2(155, 263)
    retrato.size = Vector2(170, 170)
    retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(retrato)
    _etiqueta("TRES ESCUADRONES. UNA SOLA SOMBRA.", Vector2(43, 440), Vector2(396, 28), 13, Color("bed4e8"), true)
    _etiqueta("← →  MOVER       ESPACIO  SHURIKEN", Vector2(43, 479), Vector2(396, 24), 12, Color("eaf5ff"), true)
    _etiqueta("SHIFT  ESQUIVAR        M  SILENCIO", Vector2(43, 504), Vector2(396, 24), 12, Color("eaf5ff"), true)
    _inicio = Button.new()
    _inicio.text = "▶  COMENZAR MISIÓN"
    _inicio.position = Vector2(72, 557)
    _inicio.size = Vector2(336, 55)
    _inicio.focus_mode = Control.FOCUS_NONE
    _inicio.add_theme_stylebox_override("normal", _panel(Color("184054"), Color("64edf0")))
    _inicio.add_theme_stylebox_override("hover", _panel(Color("285f6c"), Color("f4e0ff")))
    _inicio.add_theme_font_size_override("font_size", 19)
    _inicio.add_theme_color_override("font_color", Color("f5fdff"))
    _inicio.pressed.connect(_comenzar)
    add_child(_inicio)
    _etiqueta("INTRODUCCIÓN A LA PROGRAMACIÓN  ·  TP FINAL", Vector2(23, 670), Vector2(435, 23), 10, Color("7e9bb7"), true)
    _destello = ColorRect.new()
    _destello.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _destello.color = Color(0.09, 0.9, 1.0, 0.035)
    _destello.position = Vector2(25, 53)
    _destello.size = Vector2(430, 4)
    add_child(_destello)

func _process(delta: float) -> void:
    _tiempo += delta
    if _destello != null:
        _destello.position.y = 53.0 + fposmod(_tiempo * 74.0, 598.0)
    if Input.is_action_just_pressed("ui_accept"):
        _comenzar()

func _comenzar() -> void:
    if not visible:
        return
    visible = false
    comenzar.emit()
    queue_free()
