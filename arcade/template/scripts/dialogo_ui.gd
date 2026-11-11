extends CanvasLayer
## Diálogos cinematográficos: retratos, terminal con efecto de escritura y opciones.
signal opcion_elegida(opcion: Dictionary)
signal continuo
const RETRATOS := {
    "REN": preload("res://recursos/portrait_ren.png"),
    "AIKO": preload("res://recursos/portrait_aiko.png"),
    "RAIDEN": preload("res://recursos/portrait_raiden.png")
}
const COLORES := {
    "REN": Color("6cf8f2"), "AIKO": Color("80b8ff"), "RAIDEN": Color("ff577e")
}
@onready var lbl_habla: Label = $Panel/Cola/LblHabla
@onready var lbl_texto: Label = $Panel/Cola/LblTexto
@onready var caja_opciones: VBoxContainer = $Panel/Cola/Opciones
@onready var btn_seguir: Button = $Panel/Cola/BtnSeguir
var _retrato: TextureRect
var _marco: PanelContainer
var _nombre_grande: Label
var _identificador: Label
var _encabezado: Label
var _texto_completo := ""
var _progreso := 0.0
var _escribiendo := false
var _opciones_actuales: Array = []
var _es_nodo_final := false
var _tiempo := 0.0

func _ready() -> void:
    visible = false
    var base := StyleBoxFlat.new()
    base.bg_color = Color(0.016, 0.028, 0.064, 0.98)
    base.border_color = Color("36d9e5")
    base.set_border_width_all(2)
    base.set_corner_radius_all(4)
    base.content_margin_left = 17.0
    base.content_margin_right = 17.0
    base.content_margin_top = 11.0
    base.content_margin_bottom = 11.0
    $Panel.add_theme_stylebox_override("panel", base)
    btn_seguir.focus_mode = Control.FOCUS_NONE
    btn_seguir.text = "CONTINUAR  ▸"
    _estilizar_boton(btn_seguir)
    btn_seguir.pressed.connect(_on_btn_seguir)
    _crear_rostros()

func _crear_rostros() -> void:
    # La composición superior evita tapar el texto o los botones de elección.
    _marco = PanelContainer.new()
    _marco.position = Vector2(26, 137)
    _marco.size = Vector2(157, 244)
    _marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var marco_estilo := StyleBoxFlat.new()
    marco_estilo.bg_color = Color(0.018, 0.029, 0.06, 0.94)
    marco_estilo.border_color = Color("43dae7")
    marco_estilo.set_border_width_all(2)
    marco_estilo.set_corner_radius_all(4)
    _marco.add_theme_stylebox_override("panel", marco_estilo)
    add_child(_marco)
    _retrato = TextureRect.new()
    _retrato.position = Vector2(4, 4)
    _retrato.size = Vector2(149, 233)
    _retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    _retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _marco.add_child(_retrato)
    _encabezado = Label.new()
    _encabezado.position = Vector2(190, 176)
    _encabezado.size = Vector2(264, 24)
    _encabezado.text = "// CANAL CIFRADO 84"
    _encabezado.add_theme_font_size_override("font_size", 14)
    _encabezado.add_theme_color_override("font_color", Color("a5b4d4"))
    add_child(_encabezado)
    _nombre_grande = Label.new()
    _nombre_grande.position = Vector2(190, 212)
    _nombre_grande.size = Vector2(270, 46)
    _nombre_grande.add_theme_font_size_override("font_size", 32)
    add_child(_nombre_grande)
    _identificador = Label.new()
    _identificador.position = Vector2(191, 261)
    _identificador.size = Vector2(268, 70)
    _identificador.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _identificador.add_theme_font_size_override("font_size", 13)
    _identificador.add_theme_color_override("font_color", Color("d5dbec"))
    add_child(_identificador)

func _estilizar_boton(boton: Button) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("13233d")
    normal.border_color = Color("397a9a")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(3)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("244359")
    hover.border_color = Color("6bf6f1")
    boton.add_theme_stylebox_override("normal", normal)
    boton.add_theme_stylebox_override("hover", hover)
    boton.add_theme_stylebox_override("pressed", hover)
    boton.add_theme_color_override("font_color", Color("e4f5ff"))
    boton.add_theme_color_override("font_hover_color", Color.WHITE)
    boton.add_theme_font_size_override("font_size", 13)
    boton.custom_minimum_size.y = 32

func mostrar_nodo(nodo_id: String, nodo: Dictionary, opciones: Array) -> void:
    visible = true
    _tiempo = 0.0
    var hablante := str(nodo.get("spk", "AIKO"))
    var color: Color = COLORES.get(hablante, Color("56dbea"))
    _retrato.texture = RETRATOS.get(hablante, RETRATOS["AIKO"])
    _nombre_grande.text = hablante
    _nombre_grande.add_theme_color_override("font_color", color)
    lbl_habla.text = "[ %s ]  ·  %s" % [hablante, nodo_id.replace("_", " / ")]
    lbl_habla.add_theme_color_override("font_color", color)
    _encabezado.text = "// TRANSMISIÓN ENCRIPTADA"
    if hablante == "REN":
        _identificador.text = "ÚLTIMO GUARDIÁN\nCLAN KUROHANE // ACTIVO"
    elif hablante == "AIKO":
        _identificador.text = "CONSCIENCIA RESIDUAL\nSISTEMA ALIADO // ACTIVO"
    elif hablante == "RAIDEN":
        _identificador.text = "KUROGANE · DIRECTOR\nAMENAZA // CRÍTICA"
    else:
        _identificador.text = "SEÑAL IDENTIFICADA"
    var lineas := PackedStringArray(nodo.get("lineas", []))
    _texto_completo = "\n".join(lineas)
    lbl_texto.text = _texto_completo
    lbl_texto.visible_characters = 0
    _progreso = 0.0
    _escribiendo = true
    _opciones_actuales = opciones
    _es_nodo_final = bool(nodo.get("fin", false))
    for hijo in caja_opciones.get_children():
        caja_opciones.remove_child(hijo)
        hijo.queue_free()
    btn_seguir.visible = opciones.is_empty()
    btn_seguir.text = "VER DESENLACE  ▸" if _es_nodo_final else "CONTINUAR  ▸"
    for opcion in opciones:
        var boton := Button.new()
        boton.text = "›  " + str(opcion.get("txt", ""))
        boton.focus_mode = Control.FOCUS_NONE
        boton.clip_text = true
        _estilizar_boton(boton)
        boton.pressed.connect(_al_pulsar.bind(opcion))
        caja_opciones.add_child(boton)

func _process(delta: float) -> void:
    if not visible:
        return
    _tiempo += delta
    _retrato.modulate.a = 0.85 + sin(_tiempo * 2.2) * 0.07
    if _escribiendo:
        _progreso += delta * 78.0
        lbl_texto.visible_characters = int(_progreso)
        if _progreso >= float(_texto_completo.length()):
            lbl_texto.visible_characters = -1
            _escribiendo = false

func _revelar_todo() -> void:
    _escribiendo = false
    lbl_texto.visible_characters = -1

func _al_pulsar(opcion: Dictionary) -> void:
    _revelar_todo()
    visible = false
    opcion_elegida.emit(opcion)

func _on_btn_seguir() -> void:
    if _escribiendo:
        _revelar_todo()
        return
    visible = false
    continuo.emit()
