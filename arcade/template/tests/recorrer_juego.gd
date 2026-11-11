extends SceneTree
## Test integral: introduce elecciones, recorre 3 oleadas, derrota a Raiden
## mediante 72 impactos y verifica los tres finales de la historia.
const MainScript := preload("res://scripts/main.gd")
var _corrido := false

func _process(_delta: float) -> bool:
    if not _corrido:
        _corrido = true
        _correr()
    return false

func _correr() -> void:
    var main = load("res://escenas/Main.tscn").instantiate()
    root.add_child(main)
    var nodos_vistos: Dictionary = {}
    var pasos := 0
    var jefe_derrotado := false
    var fases_vistas: Dictionary = {}
    var escuadrones_por_nivel: Dictionary = {0: {}, 1: {}, 2: {}}
    while main.fase != MainScript.Fase.FINAL and pasos < 360:
        pasos += 1
        if main.dialogo.visible:
            if main.guion.nodo_actual_id != "":
                nodos_vistos[main.guion.nodo_actual_id] = true
            var botones: Array = main.dialogo.caja_opciones.get_children()
            if not botones.is_empty():
                botones[0].pressed.emit()
            else:
                main.dialogo.btn_seguir.pressed.emit()
        elif main.fase == MainScript.Fase.OLEADA:
            if main.oleada_actual == 2:
                escuadrones_ciudadela[main._suboleada] = true
            var pendientes: Array = main.enemigos.duplicate()
            if pendientes.is_empty():
                _fallo("oleada vacía que no avanza")
                return
            for enemigo in pendientes:
                main._on_enemigo_destruido(enemigo.puntos, enemigo)
                enemigo.queue_free()
        elif main.fase == MainScript.Fase.JEFE:
            var jefe = main._jefe
            if jefe == null:
                _fallo("no se creó el jefe")
                return
            var golpe := Area2D.new()
            root.add_child(golpe)
            golpe.add_to_group("disparos")
            for i in range(jefe.energia_maxima):
                jefe.bloqueo_golpe = 0.0
                jefe._al_recibir_area(golpe)
                fases_vistas[jefe.fase] = true
            golpe.queue_free()
            jefe_derrotado = jefe.eliminado
        else:
            _fallo("fase inesperada (%d)" % main.fase)
            return
    if main.fase != MainScript.Fase.FINAL:
        _fallo("no se llegó al final; pasos: %d" % pasos)
        return
    if main.oleada_actual != 2:
        _fallo("faltan oleadas")
        return
    if escuadrones_ciudadela.size() != 2:
        _fallo("ciudadela sin dos escuadrones")
        return
    if not jefe_derrotado or fases_vistas.size() < 3:
        _fallo("no se completó el jefe en sus 3 fases")
        return
    for id in ["INTRO_01", "JEFE_PREP", "JEFE_ENTRADA", "EPILOGO"]:
        if not nodos_vistos.has(id):
            _fallo("nodo no recorrido: " + id)
            return
    if not _validar_grafo(main.guion):
        return
    print("OK: menú + 3 capítulos (2 escuadrones por capítulo) + RAIDEN (3 fases) + %d nodos narrativos + final" % nodos_vistos.size())
    quit(0)

func _fallo(motivo: String) -> void:
    print("FALLO: ", motivo)
    quit(1)

func _validar_grafo(guion: Node) -> bool:
    var finales := ["FIN_SACRIFICIO", "FIN_DESPERTAR", "FIN_SHOGUN"]
    if guion.nodos.size() < 11:
        _fallo("faltan nodos narrativos")
        return false
    for id in finales:
        if not guion.nodos.has(id) or not bool(guion.nodos[id].get("fin", false)):
            _fallo("final no válido: " + id)
            return false
    var epilogo: Dictionary = guion.nodos["EPILOGO"]
    for id in finales:
        var accesible := false
        for opcion in epilogo.get("opciones", []):
            if opcion.get("goto", "") == id:
                accesible = true
        if not accesible:
            _fallo("final inaccesible: " + id)
            return false
    var condiciones := 0
    var decisiones := 0
    for id in guion.nodos:
        var nodo: Dictionary = guion.nodos[id]
        for opcion in nodo.get("opciones", []):
            if not guion.nodos.has(str(opcion.get("goto", ""))):
                _fallo("salto inválido en " + id)
                return false
            if not opcion.has("efecto") or not opcion.has("cond"):
                _fallo("opción incompleta: " + id)
                return false
            if str(opcion.get("cond", "")) != "":
                condiciones += 1
            decisiones += 1
        if str(nodo.get("goto", "")) != "" and not guion.nodos.has(str(nodo.get("goto"))):
            _fallo("goto inválido en " + id)
            return false
    if condiciones < 1 or decisiones < 2:
        _fallo("faltan condiciones o decisiones")
        return false
    return true
