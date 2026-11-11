extends CanvasLayer
## HUD con panel neón, título de capítulo, vida del jefe y pantalla final.
@onready var lbl_puntaje: Label = $LblPuntaje
@onready var lbl_vidas: Label = $LblVidas
@onready var lbl_oleada: Label = $LblOleada
@onready var lbl_mensaje: Label = $LblMensaje
var _velo_final: ColorRect
var _panel_final: PanelContainer
var _anuncio: Label
var _tiempo_anuncio := 0.0
var _barra_jefe: ProgressBar
var _texto_jefe: Label
var _texto_dash: Label
var _placa_actual: TextureRect
var _flash_dano: ColorRect
var _progreso_oleada: ProgressBar
var _texto_progreso: Label
const PLACAS := [
    preload("res://recursos/placa_capitulo_1.png"),
    preload("res://recursos/placa_capitulo_2.png"),
    preload("res://recursos/placa_capitulo_3.png"),
    preload("res://recursos/placa_capitulo_4.png")
]

func _ready() -> void:
    _construir_marcos()
    _construir_jefe()
    _construir_anuncios()
    _construir_dash()
    _construir_final()
    _construir_progreso()
    _construir_flash_dano()

func _crear_panel(color: Color, borde: Color) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = borde
    s.set_border_width_all(1)
    s.set_corner_radius_all(6)
    return s

func _construir_marcos() -> void:
    var cabecera := ColorRect.new()
    cabecera.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cabecera.color = Color(0.025, 0.045, 0.095, 0.90)
    cabecera.position = Vector2.ZERO
    cabecera.size = Vector2(480, 104)
    cabecera.z_index = -2
    add_child(cabecera)
    var linea := ColorRect.new()
    linea.mouse_filter = Control.MOUSE_FILTER_IGNORE
    linea.color = Color("27dfe7")
    linea.position = Vector2(0, 102)
    linea.size = Vector2(480, 2)
    linea.z_index = -1
    add_child(linea)
    var pie := ColorRect.new()
    pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
    pie.color = Color(0.023, 0.046, 0.085, 0.86)
    pie.position = Vector2(0, 692)
    pie.size = Vector2(480, 28)
    pie.z_index = -2
    add_child(pie)

func _construir_jefe() -> void:
    _texto_jefe = Label.new()
    _texto_jefe.position = Vector2(17, 109)
    _texto_jefe.size = Vector2(445, 19)
    _texto_jefe.add_theme_color_override("font_color", Color("ff8b9a"))
    _texto_jefe.add_theme_font_size_override("font_size", 11)
    _texto_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(_texto_jefe)
    _barra_jefe = ProgressBar.new()
    _barra_jefe.position = Vector2(54, 133)
    _barra_jefe.size = Vector2(372, 10)
    _barra_jefe.show_percentage = false
    _barra_jefe.max_value = 72
    _barra_jefe.add_theme_stylebox_override("background", _crear_panel(Color("131723"), Color("583149")))
    _barra_jefe.add_theme_stylebox_override("fill", _crear_panel(Color("ff4e71"), Color("ffa1b4")))
    add_child(_barra_jefe)
    ocultar_jefe()

func _construir_anuncios() -> void:
    _anuncio = Label.new()
    _anuncio.position = Vector2(19, 154)
    _anuncio.size = Vector2(442, 28)
    _anuncio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _anuncio.add_theme_color_override("font_color", Color("c8f9fa"))
    _anuncio.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
    _anuncio.add_theme_constant_override("shadow_offset_x", 2)
    _anuncio.add_theme_constant_override("shadow_offset_y", 2)
    _anuncio.add_theme_font_size_override("font_size", 17)
    add_child(_anuncio)
    _anuncio.visible = false

func _construir_dash() -> void:
    _texto_dash = Label.new()
    _texto_dash.position = Vector2(12, 665)
    _texto_dash.size = Vector2(265, 24)
    _texto_dash.add_theme_color_override("font_color", Color("90efff"))
    _texto_dash.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
    _texto_dash.add_theme_font_size_override("font_size", 13)
    add_child(_texto_dash)
    mostrar_dash(0.0)

func mostrar_dash(restante: float) -> void:
    if _texto_dash == null:
        return
    if restante <= 0.0:
        _texto_dash.text = "SHIFT  ◇  ESQUIVA LISTA"
        _texto_dash.add_theme_color_override("font_color", Color("90efff"))
    else:
        _texto_dash.text = "SHIFT  ◇  RECARGA %.1fs" % restante
        _texto_dash.add_theme_color_override("font_color", Color("fbbf87"))

func _construir_final() -> void:
    _velo_final = ColorRect.new()
    _velo_final.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _velo_final.color = Color(0.008, 0.012, 0.035, 0.74)
    _velo_final.position = Vector2.ZERO
    _velo_final.size = Vector2(480, 720)
    _velo_final.z_index = -1
    add_child(_velo_final)
    _panel_final = PanelContainer.new()
    _panel_final.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _panel_final.position = Vector2(19, 217)
    _panel_final.custom_minimum_size = Vector2(442, 300)
    _panel_final.add_theme_stylebox_override("panel", _crear_panel(Color(0.04, 0.06, 0.12, 0.96), Color("ed5686")))
    _panel_final.z_index = -1
    add_child(_panel_final)
    _velo_final.visible = false
    _panel_final.visible = false

func _process(delta: float) -> void:
    if _tiempo_anuncio > 0.0:
        _tiempo_anuncio -= delta
        _anuncio.visible = _tiempo_anuncio > 0.0
        _anuncio.modulate.a = minf(1.0, _tiempo_anuncio / 0.6)

func actualizar(puntaje: int, vidas: int, oleada: int) -> void:
    lbl_puntaje.text = "PUNTOS %06d" % puntaje
    lbl_vidas.text = "VIDAS  %d" % vidas
    if oleada <= 0:
        lbl_oleada.text = "SHADOW//84  •  LA ÚLTIMA SOMBRA"
    else:
        lbl_oleada.text = "CAPÍTULO %02d / 03" % oleada

func anunciar(texto: String, duracion: float = 3.0) -> void:
    _anuncio.text = texto
    _anuncio.visible = true
    _tiempo_anuncio = duracion
    _anuncio.modulate.a = 1.0

func mostrar_jefe(energia: int, maxima: int, fase: int) -> void:
    ocultar_progreso()
    _texto_jefe.visible = true
    _barra_jefe.visible = true
    _barra_jefe.max_value = maxf(1.0, float(maxima))
    _barra_jefe.value = energia
    _texto_jefe.text = "RAIDEN · %s · %d/%d" % [["DESPERTAR", "FURIA", "ÚLTIMO PROTOCOLO"][clampi(fase, 0, 2)], energia, maxima]

func ocultar_jefe() -> void:
    if _texto_jefe != null:
        _texto_jefe.visible = false
    if _barra_jefe != null:
        _barra_jefe.visible = false

func mostrar_mensaje(texto: String) -> void:
    lbl_mensaje.text = texto
    lbl_mensaje.visible = true
    _velo_final.visible = true
    _panel_final.visible = true
    _anuncio.visible = false

func ocultar_mensaje() -> void:
    lbl_mensaje.visible = false
    _velo_final.visible = false
    _panel_final.visible = false


func _construir_progreso() -> void:
    _texto_progreso = Label.new()
    _texto_progreso.position = Vector2(18, 108)
    _texto_progreso.size = Vector2(200, 19)
    _texto_progreso.add_theme_font_size_override("font_size", 11)
    _texto_progreso.add_theme_color_override("font_color", Color("a6edf2"))
    add_child(_texto_progreso)
    _progreso_oleada = ProgressBar.new()
    _progreso_oleada.position = Vector2(166, 116)
    _progreso_oleada.size = Vector2(283, 6)
    _progreso_oleada.show_percentage = false
    _progreso_oleada.add_theme_stylebox_override("background", _crear_panel(Color("0b1024"), Color("315976")))
    _progreso_oleada.add_theme_stylebox_override("fill", _crear_panel(Color("36dae3"), Color("a4ffff")))
    add_child(_progreso_oleada)
    ocultar_progreso()

func actualizar_progreso(restantes: int, totales: int) -> void:
    if _texto_progreso == null:
        return
    _texto_progreso.visible = true
    _progreso_oleada.visible = true
    _texto_progreso.text = "CENTINELAS  %02d / %02d" % [restantes, totales]
    _progreso_oleada.max_value = maxf(1.0, float(totales))
    _progreso_oleada.value = restantes

func ocultar_progreso() -> void:
    if _texto_progreso != null:
        _texto_progreso.visible = false
    if _progreso_oleada != null:
        _progreso_oleada.visible = false

func anunciar_capitulo(indice: int) -> void:
    if is_instance_valid(_placa_actual):
        _placa_actual.queue_free()
    _placa_actual = TextureRect.new()
    _placa_actual.texture = PLACAS[clampi(indice, 0, PLACAS.size() - 1)]
    _placa_actual.position = Vector2(0, 213)
    _placa_actual.size = Vector2(480, 248)
    _placa_actual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _placa_actual.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _placa_actual.modulate.a = 0.0
    add_child(_placa_actual)
    var animacion := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    animacion.tween_property(_placa_actual, "modulate:a", 1.0, 0.23)
    animacion.tween_interval(1.30)
    animacion.tween_property(_placa_actual, "modulate:a", 0.0, 0.40)
    animacion.tween_callback(_placa_actual.queue_free)

func _construir_flash_dano() -> void:
    _flash_dano = ColorRect.new()
    _flash_dano.color = Color(1.0, 0.05, 0.17, 0.0)
    _flash_dano.position = Vector2.ZERO
    _flash_dano.size = Vector2(480, 720)
    _flash_dano.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_flash_dano)

func indicar_dano() -> void:
    if _flash_dano == null:
        return
    _flash_dano.color.a = 0.27
    var animacion := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    animacion.tween_property(_flash_dano, "color:a", 0.0, 0.45)
