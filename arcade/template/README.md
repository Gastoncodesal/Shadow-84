# SHADOW//84 — La última sombra

**Trabajo práctico final — Introducción a la Programación (Godot 4.x).**

Arcade ninja cyberpunk construido sobre el template académico NEÓN 84: **tres oleadas de centinelas**, disparos, colisiones, vidas, puntaje, récord persistente, decisiones narrativas con banderas, **Raiden como jefe final de tres fases** y tres desenlaces.

## Ejecutar

Importar `project.godot` en Godot 4 y presionar **F5**. La primera apertura puede tardar mientras se importan las texturas PNG.

| Acción | Control |
| --- | --- |
| Mover a Ren | Flechas ← → |
| Lanzar shurikens | ESPACIO o ENTER |
| Esquivar disparos con dash (recarga: 4 s) | SHIFT; dirección según último movimiento |
| Silenciar / activar | Tecla M o botón ♪/× |
| Ajustar volumen | Barra superior derecha |
| Reiniciar al terminar | ENTER |

## Recorrido equilibrado

1. **Azoteas de Neo-Kyoto:** patrulla de 2×7 enemigos de un impacto. Disparos simples y espaciados; aprendizaje de controles.
2. **Distrito de la Forja:** 3×6 drones con trayectorias oscilantes y blindaje selectivo. Alterna disparos anunciados y ocasional ráfaga doble.
3. **Ciudadela Kurogane:** dos escuadrones sucesivos de 2×6 y 3×5. La mayoría de los soldados cae de un impacto; pocas unidades élite resisten dos o tres. Disparos anunciados, máximo cinco proyectiles hostiles en pantalla y un refuerzo de +1 vida si quedan menos de tres.
4. **Núcleo de Kurogane:** Raiden, jefe final de **72 HP** repartidos en tres fases de 24 HP. Sus patrones cambian progresivamente, muestran una línea de aviso y nunca generan la antigua saturación de 27 balas.

**Novedades de ritmo:** cada fase posee música original distinta, los escuadrones 2 y 3 tienen movimientos serpentinos, los enemigos telegráfan sus ataques, los combos multiplican el puntaje hasta x5 y Ren puede esquivar cada cuatro segundos.

En el guion, **liberar prisioneros** agrega una vida y **recuperar el arsenal** activa tres shurikens. Las elecciones se serializan en `guion/capitulo_1.json`.

## Arquitectura y estudio

- `scripts/main.gd`: máquina de fases, oleadas, disparos enemigos, Raiden, récord y audio.
- `scripts/jugador.gd`: movimiento, dash con recarga, cooldown, invulnerabilidad de 1,75 s y triple disparo.
- `scripts/enemigo.gd`: impacto, HP y puntuación por fila.
- `scripts/jefe.gd`: 72 HP, ataques anunciados, fases, patrones y señal de derrota.
- `scripts/proyectil_enemigo.gd`: balas hostiles.
- `scripts/guion_manager.gd`: evaluación de condiciones, efectos y saltos narrativos.
- `scripts/dialogo_ui.gd`: UI narrativa con elecciones.
- `scripts/hud.gd`: marcador, barra del jefe, transiciones y pantalla de fin.
- `scripts/arte/`: dibujo/animación de sprites y efectos climáticos.
- `recursos/`: sprites originales PNG y cuatro escenarios; arte generado para este trabajo.

## Test automatizado

En un entorno con Godot 4 instalado:

```sh
godot --headless --path . --script res://tests/recorrer_juego.gd
```

El script verifica tres oleadas (incluyendo dos escuadrones en el tercero), 72 impactos al jefe, sus tres fases y la llegada al epílogo. **El test debe ejecutarse en una computadora con Godot**; no sustituye al playtest humano.

## Entregables

- `../docs/diseno_narrativo.md` — E1: seis pasos y beats.
- `guion/capitulo_1.json` — E2: grafo de decisiones.
- Código, escenas, recursos — E3.
- `../docs/playtest.md` — E4: checklist y formulario para tres personas (pendiente de completar con resultados reales).
