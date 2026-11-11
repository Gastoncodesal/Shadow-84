# E4 — Pruebas y playtest

## Checklist de calidad
| Criterio | Estado | Evidencia / pendiente |
|---|---|---|
| Premisa en dos frases | Sí | diseno_narrativo.md |
| Cada beat jugable | Sí | 3 oleadas, tres fases del jefe y decisiones |
| Personajes con deseo, arco y voz | Sí | E1 |
| Opciones con cambio de estado | Sí | JSON efectos |
| Convergencia | Sí | Nodos CONVERGE |
| Mecánica coherente con el tema | Sí | Rescate otorga vida; arsenal da shurikens |
| Lectura breve | Sí | Líneas cortas en diálogo |
| IDs y condiciones | Sí | capitulo_1.json |
| Implementable sin interpretación | Pendiente de revisión externa | Código y documentación |
| Entendible por otro jugador | Pendiente | Playtest humano |

## Prueba automática
Comando: `godot --headless --path . --script res://tests/recorrer_juego.gd` desde `template/`. Se requiere Godot 4 instalado. Registrar aquí fecha, versión, salida y correcciones tras ejecutarlo. **No se declara un OK sin haberlo ejecutado.**

## Playtest de tres personas (completar con respuestas reales)
| Participante | ¿Qué pasó, según vos? | ¿Por qué elegiste esa opción? | ¿Qué esperabas que pasara? | Fallo observado | Cambio realizado |
|---|---|---|---|---|---|
| Jugador 1 | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |
| Jugador 2 | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |
| Jugador 3 | Pendiente | Pendiente | Pendiente | Pendiente | Pendiente |

**Informe de iteración:** completar después de jugar: qué falló, qué se cambió y por qué. No inventar pruebas humanas.


## Revisión adicional para la versión con jefe

Comprobar en Godot 4: aparición de Raiden tras completar exactamente tres oleadas; cambio de textura en fases 2 y 3; barra 72/72 → 0/72; esquiva de abanicos; impacto enemigo causa una sola vida perdida durante 1,75 s; epílogo inaccesible antes de vencer a Raiden; cuatro fondos correspondientes a la historia; botón de silencio, tecla M y persistencia del volumen tras reiniciar; triple shuriken únicamente si se elige arsenal.

**Pendiente:** ejecutar test automático y registrar tiempos y dificultades con tres jugadores reales. No inventar resultados.


## Iteración de dificultad (11/11/2026)

**Observación del usuario:** episodio 3 demasiado difícil, oleadas monótonas.

**Cambios en código:** formación 3 dividida en dos escuadrones, menos salud total de enemigos y menos disparos, avisos visuales, dash con recarga, patrones oscilantes, combo y cuatro pistas musicales. Raiden reducido a 72 HP y ataque máximo reducido a nueve proyectiles activos.

**Validación pendiente:** juego real de principio a fin con la nueva versión. Registrar número de intentos, duración y si los avisos son legibles. No se ha simulado un playtest humano.
