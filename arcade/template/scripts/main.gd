extends Node2D
## SHADOW//84 — Edición equilibrada: oleadas con mecánicas distintas, avisos y jefe jugable.
## Se conserva la máquina narrativa y la estructura del TP NEÓN 84.
enum Fase { HISTORIA, OLEADA, JEFE, FINAL, MENU }

@export var enemigo_escena: PackedScene
const JEFE_ESCENA := preload("res://escenas/Jefe.tscn")
const PANTALLA_INICIO := preload("res://scripts/pantalla_inicio.gd")
const IMPACTO_SCRIPT := preload("res://scripts/arte/impacto.gd")
const AVISO_SCRIPT := preload("res://scripts/arte/aviso_ataque.gd")
const PROYECTIL_ESCENA := preload("res://escenas/ProyectilEnemigo.tscn")
const ARCHIVO_GUION := "res://guion/capitulo_1.json"
const MUSICAS := [
    preload("res://audio/azoteas.wav"),
    preload("res://audio/forja.wav"),
    preload("res://audio/ciudadela.wav"),
    preload("res://audio/nucleo.wav")
]
const VIDAS_INICIALES := 3
const EFECTOS := {
    "shuriken": preload("res://audio/fx_shuriken.wav"),
    "impacto": preload("res://audio/fx_impacto.wav"),
    "dano": preload("res://audio/fx_dano.wav"),
    "boss": preload("res://audio/fx_boss.wav"),
    "dash": preload("res://audio/fx_dash.wav")
}
const ESPACIO_X := 52.0
const ESPACIO_Y := 45.0
const MARGEN_FORMACION := 30.0
const BAJADA_FORMACION := 18.0
const LIMITE_INFERIOR := 608.0

## Dificultad por etapa: variedad por composición, ritmo y disparos anunciados.
## El episodio 3 se divide en dos escuadrones más pequeños: NO 32 blindados a la vez.
const OLEADAS := [
    {"filas": 2, "columnas": 6, "puntos": 12, "paso": 19.0, "espera": 0.48, "hp": 1, "fuego": 2.70, "vel_bala": 166.0, "max_balas": 3},
    {"filas": 2, "columnas": 7, "puntos": 18, "paso": 22.0, "espera": 0.41, "hp": 1, "fuego": 2.15, "vel_bala": 186.0, "max_balas": 4},
    {"filas": 3, "columnas": 5, "puntos": 25, "paso": 23.0, "espera": 0.40, "hp": 1, "fuego": 2.00, "vel_bala": 194.0, "max_balas": 5},
]
const COLORES := [Color("34e9e8"), Color("f6af5b"), Color("fa5d9c")]
const TITULOS := ["01 // AZOTEAS DE NEO-KYOTO", "02 // DISTRITO DE LA FORJA", "03 // CIUDADELA KUROGANE"]
var fase: Fase = Fase.MENU
var puntaje := 0
var vidas := VIDAS_INICIALES
var oleada_actual := -1
var enemigos: Array = []
var formacion_dir := 1
var mejor_puntaje := 0
var _tiempo_paso := 0.0
var _tiempo_disparo := 0.0
var _suboleada := 0
var _avisos: Array = []
var _contador_ataques := 0
var _combo := 0
var _tiempo_combo := 0.0
var _ancho_formacion := 0.0
var _enemigos_iniciales := 1
var _jefe = null
var _azar := RandomNumberGenerator.new()
var _audio: AudioStreamPlayer
var _btn_mute: Button
var _volumen: HSlider
var _silenciado := false
var _volumen_anterior := 0.5
var _menu: CanvasLayer
var _gracia_entrada := 0.0
var _sfx: Array[AudioStreamPlayer] = []
var _tiempo_intro := 0.0

@onready var jugador = $Jugador
@onready var formacion = $Formacion
@onready var guion = $GuionManager
@onready var hud = $HUD
@onready var dialogo = $DialogoUI
@onready var fondo = $Fondo

func _ready() -> void:
    _azar.randomize()
    jugador.murio.connect(_on_jugador_murio)
    jugador.disparo_realizado.connect(func() -> void: _sonar("shuriken", -12.0))
    jugador.esquivo.connect(func() -> void: _sonar("dash", -7.5))
    dialogo.opcion_elegida.connect(_on_opcion_elegida)
    dialogo.continuo.connect(_on_continuo)
    guion.nodo_mostrado.connect(_on_nodo_mostrado)
    guion.guion_terminado.connect(_on_guion_terminado)
    _configurar_audio()
    _configurar_efectos()
    _cargar_mejor_puntaje()
    actualizar_hud()
    if not guion.cargar(ARCHIVO_GUION):
        push_error("No se pudo abrir el guion de SHADOW//84")
    _menu = CanvasLayer.new()
    _menu.set_script(PANTALLA_INICIO)
    add_child(_menu)
    _menu.connect("comenzar", _comenzar_partida)

func _comenzar_partida() -> void:
    if fase != Fase.MENU:
        return
    fase = Fase.HISTORIA
    if guion.nodos.is_empty():
        _iniciar_oleada(0)
    else:
        guion.empezar()

func _process(delta: float) -> void:
    if fase == Fase.OLEADA:
        _gracia_entrada = maxf(0.0, _gracia_entrada - delta)
        if _gracia_entrada <= 0.0:
            _mover_formacion(delta)
            _disparar_enemigos(delta)
        _procesar_avisos(delta)
    elif fase == Fase.FINAL and Input.is_action_just_pressed("ui_accept"):
        _reiniciar()
    if _tiempo_combo > 0.0:
        _tiempo_combo -= delta
        if _tiempo_combo <= 0.0:
            _combo = 0
            actualizar_hud()
    hud.mostrar_dash(jugador.tiempo_para_dash())
    if Input.is_key_pressed(KEY_M) and not _tecla_m_presionada:
        _tecla_m_presionada = true
        _alternar_silencio()
    elif not Input.is_key_pressed(KEY_M):
        _tecla_m_presionada = false
var _tecla_m_presionada := false

## ------------------------------------------------------------- narrativa --
func _on_nodo_mostrado(nodo_id: String, nodo: Dictionary) -> void:
    if nodo_id == "ENTRE_01":
        fondo.cambiar_escenario(1)
        _cambiar_musica(1)
    elif nodo_id == "ENTRE_02":
        fondo.cambiar_escenario(2)
        _cambiar_musica(2)
    elif nodo_id == "JEFE_PREP":
        fondo.cambiar_escenario(3)
        _cambiar_musica(3)
    fase = Fase.HISTORIA
    get_tree().paused = true
    dialogo.mostrar_nodo(nodo_id, nodo, guion.opciones_visibles(nodo))

func _on_opcion_elegida(opcion: Dictionary) -> void:
    get_tree().paused = false
    guion.elegir_opcion(opcion)

func _on_continuo() -> void:
    get_tree().paused = false
    guion.continuar()

func _on_guion_terminado(nodo_id: String, nodo: Dictionary) -> void:
    if bool(nodo.get("fin", false)):
        _finalizar_partida(str(nodo.get("titulo", "FIN")), str(nodo.get("mensaje", "")))
    elif nodo_id == "JEFE_ENTRADA":
        _iniciar_jefe()
    else:
        _iniciar_oleada(oleada_actual + 1)

## ------------------------------------------------------------- oleadas ----
func _iniciar_oleada(indice: int) -> void:
    if indice >= OLEADAS.size():
        _iniciar_jefe()
        return
    _borrar_proyectiles()
    _borrar_enemigos()
    oleada_actual = indice
    _suboleada = 0
    _contador_ataques = 0
    _gracia_entrada = 2.0
    fase = Fase.OLEADA
    fondo.cambiar_escenario(indice)
    _cambiar_musica(indice)
    hud.ocultar_mensaje()
    hud.ocultar_jefe()
    hud.anunciar(TITULOS[indice])
    hud.anunciar_capitulo(indice)
    jugador.doble_canon = bool(guion.banderas.get("doble_canon", false))
    if bool(guion.banderas.get("vida_extra", false)) and not bool(guion.banderas.get("vida_aplicada", false)):
        vidas += 1
        guion.banderas["vida_aplicada"] = true
    actualizar_hud()
    _crear_escuadron(indice, 0)

## Genera formaciones pequeñas y variadas; la tercera etapa tiene un segundo acto.
func _crear_escuadron(indice: int, ronda: int) -> void:
    _borrar_enemigos()
    var cfg: Dictionary = OLEADAS[indice]
    var filas: int = int(cfg["filas"])
    var columnas: int = int(cfg["columnas"])
    if ronda == 1:
        if indice == 0:
            filas = 2
            columnas = 5
        elif indice == 1:
            filas = 3
            columnas = 5
        else:
            filas = 2
            columnas = 6
    formacion_dir = -1 if ronda == 1 else 1
    _tiempo_paso = 0.0
    _tiempo_disparo = 3.0 if ronda == 1 else 2.6
    _gracia_entrada = 1.6 if ronda == 1 else 2.0
    _ancho_formacion = float(columnas - 1) * ESPACIO_X
    for fila in range(filas):
        for columna in range(columnas):
            var enemigo = enemigo_escena.instantiate()
            var hp := 1
            var tipo := (fila + indice + ronda) % 3
            # Sólo unidades blindadas concretas requieren 2 o 3 impactos.
            if indice == 1 and fila == 0 and columna % 3 == 0:
                hp = 2
            elif indice == 2 and fila == 0 and columna % 3 == 1:
                hp = 2
            # Sólo un centinela élite por capítulo, fácilmente reconocible.
            if indice == 2 and ronda == 1 and fila == 0 and columna == 3:
                hp = 3
                tipo = 2
            enemigo.configurar(tipo, hp, int(cfg["puntos"]) * (filas - fila))
            enemigo.destruido.connect(_on_enemigo_destruido.bind(enemigo))
            enemigo.golpeado.connect(func() -> void: _sonar("impacto", -11.0))
            formacion.add_child(enemigo)
            var desfase := 13.0 if indice == 1 and fila == 1 and columna % 2 == 0 else 0.0
            enemigo.position = Vector2(float(columna) * ESPACIO_X + desfase, float(fila) * ESPACIO_Y)
            # La coreografía cambia por capítulo y por escuadrón.
            var patron := indice
            if indice == 0 and ronda == 1 and columna % 3 == 0:
                patron = 1
            if indice == 1 and ronda == 1 and columna % 3 == 1:
                patron = 3
            if indice == 2 and columna % 3 == 2:
                patron = 3
            enemigo.configurar_patron(patron, float(columna) * 0.75 + float(fila))
            enemigos.append(enemigo)
    _enemigos_iniciales = enemigos.size()
    hud.actualizar_progreso(enemigos.size(), _enemigos_iniciales)
    formacion.position = Vector2(240.0 - _ancho_formacion / 2.0, 152.0 if ronda == 0 else 143.0)
    if ronda > 0:
        hud.anunciar("AIKO // SEGUNDO ESCUADRÓN · CAMBIAN LOS PATRONES", 2.4)

func _mover_formacion(delta: float) -> void:
    if enemigos.is_empty():
        return
    var cfg: Dictionary = OLEADAS[oleada_actual]
    _tiempo_paso += delta
    var proporcion := float(enemigos.size()) / float(maxi(_enemigos_iniciales, 1))
    # El final de cada formación acelera, pero con un piso para poder apuntar.
    var espera: float = float(cfg["espera"]) * lerpf(0.68, 1.0, proporcion)
    if _tiempo_paso < espera:
        return
    _tiempo_paso = 0.0
    var limite_izq := MARGEN_FORMACION
    var limite_der := 480.0 - MARGEN_FORMACION - _ancho_formacion - 14.0
    var paso: float = float(cfg["paso"])
    # Los patrulleros de la forja avanzan con una pausa rítmica distintiva.
    if oleada_actual == 1 and _contador_ataques % 3 == 2:
        paso *= 0.75
    var nuevo_x: float = formacion.position.x + paso * formacion_dir
    if nuevo_x < limite_izq or nuevo_x > limite_der:
        formacion_dir *= -1
        formacion.position.x = clampf(formacion.position.x, limite_izq, limite_der)
        formacion.position.y += BAJADA_FORMACION
        var max_filas: int = 2 if oleada_actual == 2 and _suboleada == 1 else int(cfg["filas"])
        if oleada_actual == 1 and _suboleada == 1:
            max_filas = 3
        var altura: float = float(max_filas - 1) * ESPACIO_Y + 19.0
        if formacion.position.y + altura >= LIMITE_INFERIOR:
            _finalizar_partida("NEO-KYOTO HA CAÍDO", "La defensa de Kurogane alcanzó el refugio.")
    else:
        formacion.position.x = nuevo_x

## Primero se dibuja un aviso; recién 0.7 s después aparece el proyectil.
## Así los disparos dirigidos son esquivables por reacción y no por azar.
func _disparar_enemigos(delta: float) -> void:
    _tiempo_disparo -= delta
    if _tiempo_disparo > 0.0 or enemigos.is_empty():
        return
    var cfg: Dictionary = OLEADAS[oleada_actual]
    _tiempo_disparo = float(cfg["fuego"]) * _azar.randf_range(0.88, 1.17)
    var limite: int = int(cfg["max_balas"])
    if get_tree().get_nodes_in_group("proyectiles_hostiles").size() + _avisos.size() >= limite:
        return
    var atacante: Node2D = enemigos[_azar.randi_range(0, enemigos.size() - 1)]
    if not is_instance_valid(atacante):
        return
    var origen: Vector2 = atacante.global_position + Vector2(0, 22)
    var direccion: Vector2 = Vector2.DOWN
    _contador_ataques += 1
    var dirigida := oleada_actual > 0 and _contador_ataques % 3 != 0
    if dirigida:
        direccion = (jugador.global_position - origen).normalized()
        if direccion.y < 0.32:
            direccion = Vector2.DOWN
    var aviso = Node2D.new()
    aviso.set_script(AVISO_SCRIPT)
    aviso.process_mode = Node.PROCESS_MODE_PAUSABLE
    add_child(aviso)
    aviso.configurar(origen, direccion, 0.68, COLORES[oleada_actual])
    _avisos.append({"nodo": aviso, "tiempo": 0.68, "origen": origen, "direccion": direccion, "velocidad": float(cfg["vel_bala"]), "tipo": oleada_actual, "doble": oleada_actual == 1 and _contador_ataques % 4 == 0})

func _procesar_avisos(delta: float) -> void:
    for i in range(_avisos.size() - 1, -1, -1):
        var evento: Dictionary = _avisos[i]
        evento["tiempo"] = float(evento["tiempo"]) - delta
        if float(evento["tiempo"]) > 0.0:
            continue
        if is_instance_valid(evento["nodo"]):
            evento["nodo"].queue_free()
        var origen: Vector2 = evento["origen"]
        var direccion: Vector2 = evento["direccion"]
        var rapidez: float = evento["velocidad"]
        _lanzar_bala(origen, direccion * rapidez, int(evento["tipo"]))
        if bool(evento["doble"]) and get_tree().get_nodes_in_group("proyectiles_hostiles").size() < 4:
            _lanzar_bala(origen, direccion.rotated(0.16) * rapidez, int(evento["tipo"]))
        _avisos.remove_at(i)

func _lanzar_bala(origen: Vector2, velocidad: Vector2, tipo: int) -> void:
    var bala = PROYECTIL_ESCENA.instantiate()
    add_child(bala)
    bala.configurar(origen, velocidad, mini(2, tipo))

func _limpiar_avisos() -> void:
    for evento in _avisos:
        if is_instance_valid(evento["nodo"]):
            evento["nodo"].queue_free()
    _avisos.clear()

func _on_enemigo_destruido(puntos: int, enemigo: Node2D) -> void:
    if not enemigos.has(enemigo):
        return
    if puntos > 0:
        if enemigos.size() == int(ceil(float(_enemigos_iniciales) / 2.0)) and fase == Fase.OLEADA:
            var dialogos := ["AIKO // EL CIELO EMPIEZA A DESPEJARSE", "AIKO // LAS PATRULLAS SE REORGANIZAN", "AIKO // SOLO QUEDA ROMPER LA ÚLTIMA LÍNEA"]
            hud.anunciar(dialogos[clampi(oleada_actual, 0, 2)], 2.2)
        _combo = mini(_combo + 1, 5) if _tiempo_combo > 0.0 else 1
        _tiempo_combo = 2.4
        puntaje += puntos * _combo
        _crear_impacto(enemigo.global_position, COLORES[clampi(oleada_actual, 0, 2)])
        _sonar("impacto", -12.0)
    enemigos.erase(enemigo)
    hud.actualizar_progreso(enemigos.size(), _enemigos_iniciales)
    actualizar_hud()
    if enemigos.is_empty() and fase == Fase.OLEADA:
        _oleada_superada()

func _oleada_superada() -> void:
    _borrar_proyectiles()
    if _suboleada == 0:
        # Cada capítulo tiene dos segmentos: diferentes patrones y un respiro.
        _suboleada = 1
        _crear_escuadron(oleada_actual, _suboleada)
        if oleada_actual == 2 and vidas < 3:
            vidas += 1
            hud.anunciar("AIKO // REFUERZOS · +1 VIDA", 3.1)
        actualizar_hud()
        return
    fase = Fase.HISTORIA
    hud.ocultar_progreso()
    var siguiente := oleada_actual + 1
    if siguiente >= OLEADAS.size():
        if not _mostrar_nodo_si_existe("JEFE_PREP"):
            _iniciar_jefe()
    elif not _mostrar_nodo_si_existe("ENTRE_0%d" % siguiente):
        _iniciar_oleada(siguiente)

## ------------------------------------------------------------ jefe final --
func _iniciar_jefe() -> void:
    fase = Fase.JEFE
    _borrar_proyectiles()
    _borrar_enemigos()
    fondo.cambiar_escenario(3)
    _cambiar_musica(3)
    hud.ocultar_mensaje()
    hud.ocultar_progreso()
    hud.anunciar("JEFE FINAL // RAIDEN", 3.5)
    hud.anunciar_capitulo(3)
    _sonar("boss", -6.0)
    _jefe = JEFE_ESCENA.instantiate()
    add_child(_jefe)
    _jefe.position = Vector2(240, 214)
    if bool(guion.banderas.get("sigilo", false)):
        _jefe.energia_maxima = 60
        _jefe.energia = 60
        hud.anunciar("INFILTRACIÓN // ARMADURA DE RAIDEN DEBILITADA", 3.0)
    if bool(guion.banderas.get("proteccion", false)) and vidas < 4:
        vidas += 1
        actualizar_hud()
    _jefe.derrotado.connect(_on_jefe_derrotado)
    _jefe.energia_cambiada.connect(_on_energia_jefe)
    _jefe.fase_cambiada.connect(_on_fase_jefe)
    hud.mostrar_jefe(_jefe.energia, _jefe.energia_maxima, 0)

func _on_energia_jefe(actual: int, maxima: int) -> void:
    hud.mostrar_jefe(actual, maxima, _jefe.fase)
    if actual > 0 and actual % 8 == 0:
        _crear_impacto(_jefe.global_position, Color("ff748e"), 0.8)

func _on_fase_jefe(nueva_fase: int) -> void:
    if nueva_fase == 1:
        hud.anunciar("RAIDEN // ARMADURA DESBLOQUEADA", 2.5)
    else:
        hud.anunciar("RAIDEN // PROTOCOLO DESESPERACIÓN", 2.5)

func _on_jefe_derrotado() -> void:
    if fase != Fase.JEFE:
        return
    fase = Fase.HISTORIA
    puntaje += 2500
    _crear_impacto(_jefe.global_position, Color("ff6486"), 3.5)
    _sonar("boss", -4.0)
    hud.ocultar_jefe()
    _borrar_proyectiles()
    actualizar_hud()
    if not _mostrar_nodo_si_existe("EPILOGO"):
        _finalizar_partida("VICTORIA", "Raiden ha sido derrotado.")

func _mostrar_nodo_si_existe(nodo_id: String) -> bool:
    if not guion.nodos.has(nodo_id):
        return false
    guion.mostrar_nodo(nodo_id)
    return true

## --------------------------------------------------------------- derrotas --
func _on_jugador_murio() -> void:
    if fase != Fase.OLEADA and fase != Fase.JEFE:
        return
    vidas -= 1
    _combo = 0
    _tiempo_combo = 0.0
    _sonar("dano", -6.0)
    hud.indicar_dano()
    _crear_impacto(jugador.global_position, Color("fa749c"), 1.5)
    actualizar_hud()
    if vidas <= 0:
        _finalizar_partida("GAME OVER", "Kurogane detuvo a la última sombra.")
    else:
        jugador.reaparecer()

## --------------------------------------------------------------- final -----
func _finalizar_partida(titulo: String, mensaje: String) -> void:
    fase = Fase.FINAL
    get_tree().paused = false
    _borrar_enemigos()
    _borrar_proyectiles()
    if is_instance_valid(_jefe):
        _jefe.queue_free()
    hud.ocultar_jefe()
    hud.ocultar_progreso()
    if puntaje > mejor_puntaje:
        mejor_puntaje = puntaje
        _guardar_mejor_puntaje()
    hud.mostrar_mensaje("%s\n\n%s\n\nPUNTOS %06d  ·  RÉCORD %06d\n\nENTER PARA REINICIAR" % [titulo, mensaje, puntaje, mejor_puntaje])
    actualizar_hud()

func _reiniciar() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _borrar_enemigos() -> void:
    for enemigo in formacion.get_children():
        enemigo.queue_free()
    enemigos.clear()

func _borrar_proyectiles() -> void:
    _limpiar_avisos()
    for bala in get_tree().get_nodes_in_group("proyectiles_hostiles"):
        bala.queue_free()

func _crear_impacto(origen: Vector2, color: Color, tamano: float = 1.0) -> void:
    var efecto = Node2D.new()
    efecto.set_script(IMPACTO_SCRIPT)
    add_child(efecto)
    efecto.configurar(origen, color, tamano)

func actualizar_hud() -> void:
    hud.actualizar(puntaje, vidas, oleada_actual + 1)
    if hud.has_node("LblRecord"):
        var texto := "RÉCORD %06d" % mejor_puntaje
        if _combo > 1:
            texto += "  ·  COMBO x%d" % _combo
        hud.get_node("LblRecord").text = texto

func _cargar_mejor_puntaje() -> void:
    var cfg := ConfigFile.new()
    if cfg.load("user://puntajes.cfg") == OK:
        mejor_puntaje = int(cfg.get_value("arcade", "record", 0))

func _guardar_mejor_puntaje() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("arcade", "record", mejor_puntaje)
    cfg.save("user://puntajes.cfg")

## Volumen entre partidas, control compacto y tecla M para silenciar.
func _configurar_audio() -> void:
    var controles := CanvasLayer.new()
    controles.name = "AudioUI"
    controles.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(controles)
    var panel := PanelContainer.new()
    panel.position = Vector2(334, 67)
    panel.custom_minimum_size = Vector2(138, 33)
    var estilo := StyleBoxFlat.new()
    estilo.bg_color = Color(0.04, 0.08, 0.17, 0.86)
    estilo.border_color = Color("29718c")
    estilo.set_border_width_all(1)
    estilo.set_corner_radius_all(5)
    panel.add_theme_stylebox_override("panel", estilo)
    controles.add_child(panel)
    var fila := HBoxContainer.new()
    panel.add_child(fila)
    _btn_mute = Button.new()
    _btn_mute.text = "♪"
    _btn_mute.tooltip_text = "Silenciar / activar (M)"
    _btn_mute.focus_mode = Control.FOCUS_NONE
    fila.add_child(_btn_mute)
    _volumen = HSlider.new()
    _volumen.custom_minimum_size = Vector2(90, 0)
    _volumen.min_value = 0.0
    _volumen.max_value = 1.0
    _volumen.step = 0.05
    _volumen.tooltip_text = "Volumen"
    _volumen.focus_mode = Control.FOCUS_NONE
    fila.add_child(_volumen)
    _audio = AudioStreamPlayer.new()
    _audio.stream = MUSICAS[0]
    _audio.bus = "Master"
    _audio.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(_audio)
    _audio.finished.connect(func() -> void: _audio.play())
    _btn_mute.pressed.connect(_alternar_silencio)
    _volumen.value_changed.connect(_cambiar_volumen)
    var cfg := ConfigFile.new()
    var guardado := 0.40
    if cfg.load("user://audio.cfg") == OK:
        guardado = float(cfg.get_value("audio", "volumen", 0.40))
    _volumen.value = guardado
    _cambiar_volumen(guardado)
    _audio.play()

func _configurar_efectos() -> void:
    # Pool de jugadores para no cortar el audio al lanzar varios shurikens.
    for i in range(8):
        var reproductor := AudioStreamPlayer.new()
        reproductor.bus = "Master"
        reproductor.process_mode = Node.PROCESS_MODE_PAUSABLE
        add_child(reproductor)
        _sfx.append(reproductor)

func _sonar(nombre: String, ganancia_db: float = -10.0) -> void:
    if _silenciado:
        return
    for efecto in _sfx:
        if not efecto.playing:
            efecto.stream = EFECTOS[nombre]
            efecto.volume_db = ganancia_db + linear_to_db(maxf(_volumen.value, 0.01))
            efecto.play()
            return

func _cambiar_musica(indice: int) -> void:
    if _audio == null:
        return
    var cancion = MUSICAS[clampi(indice, 0, MUSICAS.size() - 1)]
    if _audio.stream == cancion:
        return
    _audio.stream = cancion
    _audio.play()
    _audio.stream_paused = _silenciado

func _cambiar_volumen(valor: float) -> void:
    _silenciado = valor <= 0.0
    _btn_mute.text = "×" if _silenciado else "♪"
    _audio.volume_db = linear_to_db(maxf(valor, 0.0001))
    _audio.stream_paused = _silenciado
    if _silenciado:
        for efecto in _sfx:
            efecto.stop()
    if not _silenciado:
        _volumen_anterior = valor
    var cfg := ConfigFile.new()
    cfg.set_value("audio", "volumen", valor)
    cfg.save("user://audio.cfg")

func _alternar_silencio() -> void:
    if _silenciado:
        _volumen.value = maxf(_volumen_anterior, 0.25)
    else:
        _volumen_anterior = maxf(_volumen.value, 0.25)
        _volumen.value = 0.0
