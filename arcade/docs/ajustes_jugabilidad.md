# SHADOW//84 — Ajustes de jugabilidad y ritmo (v1.1)

## Motivo del cambio

En una prueba real, el jugador informó que la tercera etapa era prácticamente imposible y que las oleadas se sentían monótonas. El episodio 3 tenía una formación 4×8 con gran resistencia y disparos frecuentes, mientras que los episodios compartían el mismo patrón visual de marcha.

## Solución aplicada

| Elemento | Antes | Ahora |
|---|---|---|
| Azoteas | 18 enemigos (3×6) | 14 (2×7), disparos básicos |
| Forja | 21 enemigos (3×7), mayor resistencia | 18 (3×6), zigzag y algunas unidades blindadas |
| Ciudadela | 32 (4×8), numerosos enemigos de 2–3 HP | 12 + 15, dos escuadrones, mayoría 1 HP |
| Cadencia ciudadela | Disparo cada ~1,02 s más ráfagas | ~1,85 s, máximo cinco proyectiles, ataques anunciados |
| Jefe | 96 HP, hasta 27 proyectiles simultáneos | 72 HP, máximo nueve proyectiles antes de un nuevo ataque |
| Defensa del jugador | Movimiento horizontal | Dash SHIFT: desplazamiento 124 px, 0,43 s de protección y 4 s de recarga |
| Entorno | Loop musical único de 8 s | Cuatro loops originales, uno por escenario |
| Objetivo adicional | Eliminar enemigos | Mantener combos de hasta x5 puntos y esquivar avisos |

## Criterio de diseño

La dificultad se mantiene progresiva por **patrones, precisión y reacción**, no por acumulación de balas y enemigos con demasiada vida. Los ataques dirigidos se anuncian mediante líneas segmentadas 0,68–0,78 s antes de salir, para que el jugador pueda apartarse o utilizar dash. El cambio a dos escuadrones da ritmo a la última oleada y permite refuerzo de vida si está en desventaja.

Los recursos del guion, cuatro escenarios, control de volumen, bandera `doble_canon`, tres finales y prueba `tests/recorrer_juego.gd` se conservan. El juego sigue cumpliendo el esquema académico de tres oleadas principales.

## Verificación pendiente en Godot

- Ejecutar `godot --headless --path . --script res://tests/recorrer_juego.gd` desde `template`.
- Jugar con ambas elecciones narrativas (rescate/arsenal), especialmente el episodio 3.
- Confirmar que los avisos aparecen y que SHIFT esquiva correctamente.
- Medir el tiempo de cada fase y ajustar la cadencia después de dos o tres playtests reales.

**No se afirmó que la nueva compilación pasó el motor:** esta entrega no puede ejecutar Godot desde el entorno de edición utilizado.
