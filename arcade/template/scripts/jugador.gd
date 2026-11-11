extends CharacterBody2D
## Ren: movimiento, shurikens, daño temporalmente bloqueado y esquiva (SHIFT).
signal murio
@export var disparo_escena: PackedScene
const VELOCIDAD := 312.0
const ENFRIAMIENTO := 0.265
const MARGEN_LATERAL := 29.0
const DURACION_INVULNERABILIDAD := 1.75
const DISTANCIA_DASH := 124.0
const RECARGA_DASH := 4.0
var doble_canon := false
var invulnerable := false
var _enfriamiento := 0.0
var _posicion_inicial := Vector2.ZERO
var _invulnerabilidad_restante := 0.0
var _recarga_dash := 0.0
var _shift_previo := false
var _ultima_direccion := 1.0

func _ready() -> void:
    _posicion_inicial = position

func _physics_process(delta: float) -> void:
    _recarga_dash = maxf(0.0, _recarga_dash - delta)
    if _invulnerabilidad_restante > 0.0:
        _invulnerabilidad_restante = maxf(0.0, _invulnerabilidad_restante - delta)
        invulnerable = _invulnerabilidad_restante > 0.0
        $Sprite.visible = not invulnerable or int(_invulnerabilidad_restante * 13.0) % 2 == 0
    else:
        invulnerable = false
        $Sprite.visible = true
    var direccion := Input.get_axis("ui_left", "ui_right")
    if absf(direccion) > 0.2:
        _ultima_direccion = signf(direccion)
    velocity = Vector2(direccion * VELOCIDAD, 0.0)
    move_and_slide()
    var ancho := get_viewport_rect().size.x
    position.x = clampf(position.x, MARGEN_LATERAL, ancho - MARGEN_LATERAL)
    var shift := Input.is_key_pressed(KEY_SHIFT)
    if shift and not _shift_previo and _recarga_dash <= 0.0:
        _intentar_dash(ancho)
    _shift_previo = shift
    _enfriamiento = maxf(0.0, _enfriamiento - delta)
    if Input.is_action_pressed("ui_accept") and _enfriamiento == 0.0:
        _disparar()

func _intentar_dash(ancho: float) -> void:
    var nuevo_x := clampf(position.x + _ultima_direccion * DISTANCIA_DASH, MARGEN_LATERAL, ancho - MARGEN_LATERAL)
    if absf(nuevo_x - position.x) < 16.0:
        return
    position.x = nuevo_x
    _recarga_dash = RECARGA_DASH
    _invulnerabilidad_restante = maxf(_invulnerabilidad_restante, 0.43)
    invulnerable = true
    $Sprite.atacar()

func tiempo_para_dash() -> float:
    return _recarga_dash

func _disparar() -> void:
    _enfriamiento = ENFRIAMIENTO if not doble_canon else ENFRIAMIENTO + 0.042
    $Sprite.atacar()
    var posiciones := [position + Vector2(0, -30)]
    if doble_canon:
        posiciones.append(position + Vector2(-16, -25))
        posiciones.append(position + Vector2(16, -25))
    for pos in posiciones:
        var bala := disparo_escena.instantiate()
        get_parent().add_child(bala)
        bala.position = pos

func recibir_dano() -> void:
    if invulnerable:
        return
    invulnerable = true
    _invulnerabilidad_restante = DURACION_INVULNERABILIDAD
    murio.emit()

func reaparecer() -> void:
    position = _posicion_inicial
    invulnerable = true
    _invulnerabilidad_restante = DURACION_INVULNERABILIDAD
