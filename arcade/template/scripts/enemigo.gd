extends Area2D
## Centinela: resistencia por oleada, puntuación por fila y daño por choque.
signal destruido(puntos: int)
signal golpeado
@export var puntos: int = 10
var resistencia := 1
var tipo := 0
var muerto := false
var patron := 0
var _tiempo := 0.0
var _base := Vector2.ZERO
var _desfase := 0.0

func configurar_patron(modo: int, desfase: float) -> void:
    patron = modo
    _desfase = desfase
    _base = position

func _process(delta: float) -> void:
    _tiempo += delta
    if patron == 1:
        # Forja: piezas zigzaguean entre cintas transportadoras.
        position = _base + Vector2(sin(_tiempo * 2.1 + _desfase) * 10.0, sin(_tiempo * 1.2 + _desfase) * 3.5)
    elif patron == 2:
        # Ciudadela: trazas elípticas para anticipar movimientos.
        position = _base + Vector2(sin(_tiempo * 1.65 + _desfase) * 13.0, cos(_tiempo * 1.9 + _desfase) * 8.0)
    elif patron == 3:
        # Incursión vertical: se separan de la línea, descienden y regresan.
        # No persiguen al jugador; su trayectoria se puede aprender.
        var pulso := maxf(0.0, sin(_tiempo * 0.93 + _desfase))
        position = _base + Vector2(sin(_tiempo * 1.55 + _desfase) * 19.0, pulso * 79.0)

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)
    $Sprite.variante = tipo
func configurar(variante: int, hp: int, valor: int) -> void:
    tipo = clampi(variante, 0, 2)
    resistencia = maxi(hp, 1)
    puntos = valor
    if has_node("Sprite"):
        $Sprite.variante = tipo
func colorear(_color: Color) -> void:
    # Compatibilidad con el método original de NEÓN 84.
    pass
func _on_body_entered(body: Node2D) -> void:
    if muerto:
        return
    if body.has_method("recibir_dano"):
        body.recibir_dano()
    muerto = true
    destruido.emit(0)
    queue_free()
func _on_area_entered(area: Area2D) -> void:
    if muerto or not area.is_in_group("disparos"):
        return
    if area.has_method("impacto"):
        area.impacto()
    resistencia -= 1
    golpeado.emit()
    $Sprite.destello = 0.13
    if resistencia <= 0:
        muerto = true
        destruido.emit(puntos)
        queue_free()
