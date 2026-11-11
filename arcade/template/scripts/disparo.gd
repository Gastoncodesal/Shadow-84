extends Area2D
## Shuriken de pulso: se mueve hacia arriba y destruye al impactar.
const VELOCIDAD := 600.0
func _ready() -> void:
    add_to_group("disparos")
func _physics_process(delta: float) -> void:
    position.y -= VELOCIDAD * delta
    if position.y < -26.0:
        queue_free()
func impacto() -> void:
    queue_free()
