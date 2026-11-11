extends Node
## Carga un guion serializado en JSON (formato de la clase "Creación de
## guiones para juegos") y lo recorre como una máquina de estados.
##
## Estructura del archivo:
##   { "entrada": "ID_DEL_PRIMER_NODO", "nodos": { "ID": {...}, ... } }
##
## Campos de cada nodo:
##   spk      quién habla (etiqueta del hablante)
##   lineas   array de strings (1 a 3 frases por línea)
##   opciones [{ "txt": ..., "cond": ..., "efecto": ..., "goto": ... }]
##   cond     condición de entrada del nodo (opcional)
##   goto     salto sin elección (para nodos sin opciones)
##   fin      true si el nodo cierra el guion (un final)
##
## El motor no entiende "historia": entiende estados, condiciones y saltos.
## Este script es el traductor.

signal nodo_mostrado(nodo_id: String, nodo: Dictionary)
signal guion_terminado(nodo_id: String, nodo: Dictionary)

var nodos: Dictionary = {}
var banderas: Dictionary = {}
var nodo_actual_id: String = ""

var _entrada: String = ""

func cargar(ruta: String) -> bool:
	var archivo := FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		push_error("Guion: no se pudo abrir %s" % ruta)
		return false
	var datos: Variant = JSON.parse_string(archivo.get_as_text())
	if datos == null or not (datos is Dictionary):
		push_error("Guion: JSON inválido en %s" % ruta)
		return false
	nodos = datos.get("nodos", {})
	_entrada = str(datos.get("entrada", ""))
	banderas = {}
	nodo_actual_id = ""
	return not nodos.is_empty()

func empezar() -> void:
	if _entrada != "":
		mostrar_nodo(_entrada)

func mostrar_nodo(nodo_id: String) -> void:
	if not nodos.has(nodo_id):
		push_error("Guion: nodo inexistente '%s'" % nodo_id)
		return
	nodo_actual_id = nodo_id
	nodo_mostrado.emit(nodo_id, nodos[nodo_id])

## Devuelve sólo las opciones cuya condición se cumple con las banderas
## actuales. El resto no se muestra (una opción inaccesible no es una elección).
func opciones_visibles(nodo: Dictionary) -> Array:
	var visibles: Array = []
	for opcion in nodo.get("opciones", []):
		if _cumple(opcion.get("cond")):
			visibles.append(opcion)
	return visibles

func elegir_opcion(opcion: Dictionary) -> void:
	_aplicar(opcion.get("efecto"))
	var destino := str(opcion.get("goto", ""))
	if destino != "" and nodos.has(destino):
		mostrar_nodo(destino)
	else:
		_cerrar()

## Avanza un nodo que no tiene opciones (sólo "goto" o "fin").
func continuar() -> void:
	var nodo: Dictionary = nodos.get(nodo_actual_id, {})
	var destino := str(nodo.get("goto", ""))
	if bool(nodo.get("fin", false)) or destino == "" or not nodos.has(destino):
		_cerrar()
	else:
		mostrar_nodo(destino)

func _cerrar() -> void:
	guion_terminado.emit(nodo_actual_id, nodos.get(nodo_actual_id, {}))

## Evalúa una condición del guion:
##   null / ""      -> siempre se cumple
##   "bandera"      -> true si la bandera existe y vale true o distinto de 0
##   "a == b"       -> comparación (también !=, >=, <=, >, <)
func _cumple(expresion: Variant) -> bool:
	var texto := "" if expresion == null else str(expresion).strip_edges()
	if texto == "":
		return true
	for operador in [">=", "<=", "==", "!=", ">", "<"]:
		if texto.contains(operador):
			var partes := texto.split(operador, true, 1)
			var izquierda: Variant = _valor(partes[0])
			var derecha: Variant = _valor(partes[1])
			match operador:
				">=": return izquierda >= derecha
				"<=": return izquierda <= derecha
				"==": return izquierda == derecha
				"!=": return izquierda != derecha
				">": return izquierda > derecha
				"<": return izquierda < derecha
	var valor: Variant = _valor(texto)
	match typeof(valor):
		TYPE_BOOL:
			return valor
		TYPE_INT, TYPE_FLOAT:
			return valor != 0
	return false

## Aplica el efecto de una elección: sentencias separadas por ";" de la
## forma "bandera = valor", "bandera += 1" o "bandera -= 1".
func _aplicar(expresion: Variant) -> void:
	var texto := "" if expresion == null else str(expresion).strip_edges()
	if texto == "":
		return
	for sentencia in texto.split(";"):
		var sent := sentencia.strip_edges()
		if sent == "":
			continue
		for operador in ["+=", "-=", "="]:
			if sent.contains(operador):
				var partes := sent.split(operador, true, 1)
				var clave := partes[0].strip_edges()
				var valor: Variant = _valor(partes[1])
				match operador:
					"+=":
						banderas[clave] = float(banderas.get(clave, 0)) + float(valor)
					"-=":
						banderas[clave] = float(banderas.get(clave, 0)) - float(valor)
					_:
						banderas[clave] = valor
				break

## Convierte un texto a su valor: bandera conocida, literal (true/false/
## número) o, en último caso, el texto mismo.
func _valor(expresion: String) -> Variant:
	var texto := expresion.strip_edges()
	if banderas.has(texto):
		return banderas[texto]
	match texto:
		"true":
			return true
		"false":
			return false
	if texto.is_valid_int():
		return texto.to_int()
	if texto.is_valid_float():
		return texto.to_float()
	return texto
