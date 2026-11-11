extends CanvasLayer
## UI narrativa: un panel azul noche, opciones neón y lectura a ritmo propio.
signal opcion_elegida(opcion: Dictionary)
signal continuo
@onready var lbl_habla: Label = $Panel/Cola/LblHabla
@onready var lbl_texto: Label = $Panel/Cola/LblTexto
@onready var caja_opciones: VBoxContainer = $Panel/Cola/Opciones
@onready var btn_seguir: Button = $Panel/Cola/BtnSeguir

func _ready() -> void:
	visible = false
	var base := StyleBoxFlat.new()
	base.bg_color = Color(0.035, 0.054, 0.12, 0.98)
	base.border_color = Color("36cbd5")
	base.set_border_width_all(2)
	base.set_corner_radius_all(7)
	base.content_margin_left = 18.0
	base.content_margin_right = 18.0
	base.content_margin_top = 13.0
	base.content_margin_bottom = 13.0
	$Panel.add_theme_stylebox_override("panel", base)
	btn_seguir.focus_mode = Control.FOCUS_NONE
	_estilizar_boton(btn_seguir)
	btn_seguir.pressed.connect(_on_btn_seguir)

func _estilizar_boton(boton: Button) -> void:
	var base := StyleBoxFlat.new()
	base.bg_color = Color("13233e")
	base.border_color = Color("327c99")
	base.set_border_width_all(1)
	base.set_corner_radius_all(4)
	var hover := base.duplicate() as StyleBoxFlat
	hover.bg_color = Color("243a55")
	hover.border_color = Color("53f0e9")
	boton.add_theme_stylebox_override("normal", base)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", hover)
	boton.add_theme_color_override("font_color", Color("defbff"))
	boton.add_theme_color_override("font_hover_color", Color("ffffff"))
	boton.add_theme_font_size_override("font_size", 14)
	boton.custom_minimum_size.y = 30

func mostrar_nodo(_nodo_id: String, nodo: Dictionary, opciones: Array) -> void:
	visible = true
	var hablante := str(nodo.get("spk", ""))
	lbl_habla.text = "▸ " + hablante + " // TRANSMISIÓN"
	if hablante == "RAIDEN":
		lbl_habla.add_theme_color_override("font_color", Color("ff7a91"))
	elif hablante == "REN":
		lbl_habla.add_theme_color_override("font_color", Color("f0e5ff"))
	else:
		lbl_habla.add_theme_color_override("font_color", Color("49ede6"))
	var lineas := PackedStringArray(nodo.get("lineas", []))
	lbl_texto.text = "\n".join(lineas)
	for hijo in caja_opciones.get_children():
		caja_opciones.remove_child(hijo)
		hijo.queue_free()
	btn_seguir.visible = opciones.is_empty()
	for opcion in opciones:
		var boton := Button.new()
		boton.text = "›  " + str(opcion.get("txt", ""))
		boton.focus_mode = Control.FOCUS_NONE
		_estilizar_boton(boton)
		boton.pressed.connect(_al_pulsar.bind(opcion))
		caja_opciones.add_child(boton)

func _al_pulsar(opcion: Dictionary) -> void:
	visible = false
	opcion_elegida.emit(opcion)

func _on_btn_seguir() -> void:
	visible = false
	continuo.emit()
