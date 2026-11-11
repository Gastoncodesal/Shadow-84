extends Area2D
## Raiden: pelea en tres fases, con ventanas de ataque y señales visuales.
signal derrotado
signal fase_cambiada(fase: int)
signal energia_cambiada(actual: int, maxima: int)
const PROYECTIL := preload("res://escenas/ProyectilEnemigo.tscn")
const AVISO_SCRIPT := preload("res://scripts/arte/aviso_ataque.gd")
const ENERGIA_MAXIMA := 72
var energia_maxima: int = ENERGIA_MAXIMA
var energia: int = ENERGIA_MAXIMA
var fase: int = 0
var tiempo := 0.0
var temporizador := 1.8
var bloqueo_golpe := 0.0
var eliminado := false
var secuencia := 0
var _avisando := false
var _tiempo_aviso := 0.0
var _direccion_anunciada := Vector2.DOWN
var _origen_anunciado := Vector2.ZERO
var _marca: Node2D

func _ready() -> void:
    area_entered.connect(_al_recibir_area)
    body_entered.connect(_al_tocar_jugador)
    energia_cambiada.emit(energia, energia_maxima)

func _process(delta: float) -> void:
    if eliminado:
        return
    tiempo += delta
    bloqueo_golpe = maxf(0.0, bloqueo_golpe - delta)
    position.x = 240.0 + sin(tiempo * (0.70 + fase * 0.13)) * (92.0 + fase * 9.0)
    position.y = 214.0 + sin(tiempo * 1.32) * 9.0
    if _avisando:
        _tiempo_aviso -= delta
        if _tiempo_aviso <= 0.0:
            _avisando = false
            if is_instance_valid(_marca):
                _marca.queue_free()
            _atacar(_origen_anunciado, _direccion_anunciada)
            temporizador = [1.70, 1.54, 1.34][fase]
    else:
        temporizador -= delta
        if temporizador <= 0.0:
            _preparar_ataque()

func _preparar_ataque() -> void:
    if get_tree().get_nodes_in_group("proyectiles_hostiles").size() >= 9:
        temporizador = 0.38
        return
    _avisando = true
    _tiempo_aviso = 0.78
    _origen_anunciado = global_position + Vector2(0, 53)
    var objetivo := get_parent().get_node_or_null("Jugador")
    _direccion_anunciada = Vector2.DOWN
    if objetivo != null:
        _direccion_anunciada = (objetivo.global_position - _origen_anunciado).normalized()
    _marca = Node2D.new()
    _marca.set_script(AVISO_SCRIPT)
    _marca.process_mode = Node.PROCESS_MODE_PAUSABLE
    get_parent().add_child(_marca)
    _marca.call("configurar", _origen_anunciado, _direccion_anunciada, _tiempo_aviso, Color("ff697a"))

func _al_recibir_area(area: Area2D) -> void:
    if eliminado or bloqueo_golpe > 0.0 or not area.is_in_group("disparos"):
        return
    bloqueo_golpe = 0.085
    if area.has_method("impacto"):
        area.impacto()
    energia = maxi(0, energia - 1)
    $Sprite.destello = 0.10
    var nueva_fase := 0
    if energia <= 24:
        nueva_fase = 2
    elif energia <= 48:
        nueva_fase = 1
    if nueva_fase != fase:
        fase = nueva_fase
        $Sprite.fase_visual = fase
        temporizador = maxf(temporizador, 0.65)
        fase_cambiada.emit(fase)
    energia_cambiada.emit(energia, energia_maxima)
    if energia <= 0:
        eliminado = true
        if is_instance_valid(_marca):
            _marca.queue_free()
        derrotado.emit()
        queue_free()

func _al_tocar_jugador(cuerpo: Node2D) -> void:
    if cuerpo.has_method("recibir_dano"):
        cuerpo.recibir_dano()

func _atacar(origen: Vector2, direccion: Vector2) -> void:
    if eliminado:
        return
    secuencia += 1
    if fase == 0:
        _abanico(origen, direccion, 3, 0.29, 195.0, 0)
    elif fase == 1:
        if secuencia % 3 == 0:
            _abanico(origen, Vector2.DOWN, 4, 0.23, 209.0, 1)
        else:
            _abanico(origen, direccion, 3, 0.21, 212.0, 1)
    elif secuencia % 2 == 0:
        _abanico(origen, Vector2.DOWN, 5, 0.21, 220.0, 2)
    else:
        _abanico(origen, direccion, 4, 0.19, 228.0, 2)

func _abanico(origen: Vector2, direccion: Vector2, cantidad: int, separacion: float, rapidez: float, tipo: int) -> void:
    for i in range(cantidad):
        if get_tree().get_nodes_in_group("proyectiles_hostiles").size() >= 9:
            break
        var angulo: float = (float(i) - float(cantidad - 1) / 2.0) * separacion
        var vuelo: Vector2 = direccion.rotated(angulo).normalized() * rapidez
        var bala = PROYECTIL.instantiate()
        get_parent().add_child(bala)
        bala.configurar(origen, vuelo, tipo)
