extends Area2D
## Proyectil hostil: sólo afecta al jugador; se elimina al impactar o salir.
var velocidad: Vector2 = Vector2(0, 200)
var variante: int = 0
var activo := true
func _ready() -> void:
	add_to_group("proyectiles_hostiles")
	$Arte.tipo = variante
	body_entered.connect(_impacto)
func configurar(origen: Vector2, vector: Vector2, aspecto: int = 0) -> void:
	position = origen
	velocidad = vector
	variante = aspecto
	if has_node("Arte"):
		$Arte.tipo = variante
func _physics_process(delta: float) -> void:
	position += velocidad * delta
	if position.y < -40 or position.y > 765 or position.x < -48 or position.x > 528:
		queue_free()
func _impacto(cuerpo: Node2D) -> void:
	if not activo:
		return
	if cuerpo.has_method("recibir_dano"):
		activo = false
		cuerpo.recibir_dano()
		queue_free()
