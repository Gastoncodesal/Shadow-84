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

func _ready() -> void:
	_construir_marcos()
	_construir_jefe()
	_construir_anuncios()
	_construir_dash()
	_construir_final()

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
