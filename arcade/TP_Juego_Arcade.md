# TP: NEÓN 84 — Un juego arcade con guion (Godot 4)

> **Materia:** Introducción a la Programación · Tecnicatura en Desarrollo de Software · 2026
> **Temática:** juegos de arcade antiguos (ola de invasores, vidas, puntaje récord)
> **Motor:** Godot 4.x con GDScript · **Guion:** proceso de 8 pasos de la clase _Creación de guiones para juegos_
> **Formato:** individual o dupla · **Duración sugerida:** 3 clases

---

## 1. Objetivos

Al terminar este TP vas a poder:

1. Aplicar los **8 pasos de la guía de guiones** (premisa → tema → mundo → personajes → estructura → ramificación → escritura → integración) a un juego jugable.
2. Diseñar un guion como **sistema de posibilidades**: nodos, condiciones, efectos, saltos y finales convergentes.
3. **Serializar ese guion a JSON** y versionarlo como se versiona el código.
4. Implementar en **Godot 4** un arcade completo: escenas, nodos, señales, instanciación, colisiones y una máquina de estados.
5. Traducir guion a lenguaje del motor: _nodo → escena/diccionario, condición → bandera, efecto → actualización de estado, salto → transición_.
6. Verificar lo hecho con una **corrida automática** y un **playtest** con preguntas concretas.

---

## 2. Contexto: por qué un arcade y por qué un guion

El arcade clásico (_Space Invaders_, _Galaga_, _Defender_) es mínimos de
narrativa: una premisa en la pantalla de inicio, una mecánica pura y un
puntaje. Precisamente por eso es el mejor territorio para practicar guion:
**la historia no puede ser un monólogo, tiene que jugarse**.

En este TP el puente entre la guía de guiones y el motor es la regla de oro de
la clase:

> En el cine el guion decide el orden. En el juego el guion decide el **menú de posibilidades**.

Tu arcade tendrá:

- **Oleadas** como _beats_ de estructura (hook → incidente → midpoint → clímax → resolución).
- **Diálogos entre oleadas** serializados en JSON (formato de los campos mínimos de la guía).
- **Decisiones con banderas** (`bandera = true`) que condicionan opciones posteriores.
- **Finales múltiples** que convergen en un único nodo epílogo.

Y una exigencia ludonarrativa: **la mecánica tiene que demostrar el tema**.
Si tu historia habla de proteger a la ciudad, el juego tiene que premiar
proteger a la ciudad (p. ej. un arma o poder que se desbloquea por esa
decisión), no sólo matar enemigos.

---

## 3. El juego base: NEÓN 84

Defensa de la ciudad contra una flota de invasores. Nave vertical, oleadas
crecientes, vidas y récord.

| Elemento             | Regla                                                                              |
| -------------------- | ---------------------------------------------------------------------------------- |
| **Objetivo**   | Sobrevivir a 3 oleadas de invasores y llegar al epílogo del guion                 |
| **Movimiento** | ← → para mover la nave (no puede salirse de la pantalla)                         |
| **Disparo**    | ENTER o ESPACIO; con enfriamiento (no es ametralladora infinita)                   |
| **Oleadas**    | 3 oleadas: más filas, pasos más largos y menos espera entre pasos                |
| **Formación** | Los invasores marchan en bloque: rebotan en los bordes y bajan un renglón         |
| **Puntaje**    | Cada fila vale distinto: cuanto más arriba nació el invasor, más puntos         |
| **Vidas**      | 3; al ser alcanzado perdés una y la nave reaparece                                |
| **Derrota**    | Vidas en 0 **o** la formación llega al fondo de la pantalla                 |
| **Victoria**   | Superada la oleada 3 → nodo `EPILOGO` → uno de los finales según tus banderas |
| **Récord**    | Se guarda entre partidas (`user://puntajes.cfg`)                                 |

---

## 4. El template

Ubicación: `games/arcade/template/` (repositorio de la materia).

```bash
cd games/arcade/template
godot --path . --editor     # abrir en el editor
godot --path .              # jugar (o F5)
```

Verificación automática (recorre guion + 3 oleadas de punta a punta):

```bash
godot --headless --path . --script res://tests/recorrer_juego.gd
# salida esperada: OK: recorrido completo — 9 nodos de guion, 3 oleadas, ... fase FINAL
```

| Archivo                                                        | Rol                                     | Estado                     |
| -------------------------------------------------------------- | --------------------------------------- | -------------------------- |
| `escenas/Main.tscn`                                          | orquestador: formación, HUD, diálogo  | armado                     |
| `escenas/Jugador.tscn` / `Enemigo.tscn` / `Disparo.tscn` | nave, invasor, bala                     | armados                    |
| `scripts/main.gd`                                            | oleadas, puntaje, vidas, finales        | casi completo (1 TODO)     |
| `scripts/jugador.gd`                                         | movimiento, disparo, daño              | casi completo (1 TODO)     |
| `scripts/enemigo.gd`                                         | colisiones y destrucción               | casi completo (1 TODO)     |
| `scripts/guion_manager.gd`                                   | JSON → máquina de estados → banderas | completo (extensión TODO) |
| `scripts/dialogo_ui.gd`                                      | pinta nodos, líneas y opciones         | completo (1 TODO opcional) |
| `guion/capitulo_1.json`                                      | **guion de ejemplo**              | a reemplazar por el tuyo   |

**Lo que ya funciona** (leelo con calma, es tu material de estudio): oleadas,
HUD, récord, guion con condiciones y finales, diálogo que pausa el juego, y
el cableado `bandera → mecánica` (`doble_canon`).

**Lo que tenés que hacer** está marcado con `# TODO(TP):` en el código.

---

## 5. Consigna — cuatro entregables

### E1 · Diseño narrativo (Pasos 1 a 6 de la guía)

Documento de **1 a 2 páginas** con seis bloques cortos. Se cierra **antes**
de tocar el guion JSON (regla de la guía: escribir sin estructura es la causa
nº 1 de guiones que se rehacen completos).

| Paso               | Qué tenés que entregar                                                                                                                                      | Mínimo exigido                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| 1 · Premisa       | Logline (2 frases: protagonista, objetivo, obstáculo, apuesta) + promesa al jugador + 2 referencias                                                          | 2 frases, sin adjetivos vacíos                         |
| 2 · Tema          | Tema como **oración discutible** + pregunta dramática                                                                                                 | tiene que poder jugarse, no sólo contarse              |
| 3 · Mundo         | Biblia breve: reglas del mundo (¿por qué hay flotas y faros?), 5 entradas de glosario                                                                       | reglas que no contradigan el arcade                     |
| 4 · Personajes    | 2 fichas: deseo, necesidad, arco, voz, antagonismo                                                                                                            | al menos uno fuera de pantalla (el mando enemigo sirve) |
| 5 · Estructura    | **Beat sheet de 7 filas** con % de avance: qué pasa en pantalla en cada beat                                                                           | los beats se mapean a las 3 oleadas + intro + epílogo  |
| 6 · Ramificación | **Grafo Y con convergencia**: 2 decisiones que se juntan + nodos de final; anotar qué bandera cambia cada opción y cuánto contenido agrega cada rama | 1 convergencia visible, costo estimado por rama         |

**Check de la premisa antes de entregar:** ¿se explica sin usar la palabra
«increíble»? ¿se infiere una mecánica jugable? ¿alguien puede repetirla de
memoria? ¿deja una duda que da ganas de ver resuelta?

### E2 · El guion serializado (`guion/capitulo_1.json`)

Reescribí el guion de ejemplo con **tu historia**, respetando los campos
mínimos de la guía (`spk`, `lineas`, `opciones`, `cond`, `efecto`, `goto`,
`fin`, `notas_direccion`).

| Requisito                             | Mínimo                                                              |
| ------------------------------------- | -------------------------------------------------------------------- |
| Nodos totales                         | **8 o más** (además de los finales)                          |
| Decisiones del jugador                | **2 o más**, cada una con `cond` y `efecto` explícitos   |
| Opción con condición de visibilidad | **1 o más** (sólo aparece si se cumple una bandera)          |
| Finales                               | **3**, todos alcanzables desde el epílogo                     |
| Convergencia                          | obligatoria: las ramas de las decisiones se juntan antes del clímax |
| Efectos                               | toda elección cambia **algo medible**: bandera o contador     |

Reglas duras (de la guía):

- **ID estable y único** por nodo: `INTRO_01`, `ENTRE_01`, `FIN_SACRIFICIO`…
- Si la elección no cambia estado, texto, acceso o relación: **no es una
  elección** (falsa ilusión de elección = 0 puntos en la rúbrica).
- Cada bifurcación **duplica** lo que viene después salvo convergencia:
  contá el costo antes de agregar la tercera decisión.

### E3 · Implementación en Godot

Traducción motor ↔ guion (tabla de la clase, aplicada al template):

| Guion            | Godot / GDScript                                                |
| ---------------- | --------------------------------------------------------------- |
| Nodo de diálogo | entrada de `nodos` en el JSON + `Dictionary`                |
| Condición       | bandera en `guion.banderas` (leída por `_cumple`)          |
| Efecto           | actualización de `guion.banderas` (escrita por `_aplicar`) |
| Salto `goto`   | `mostrar_nodo(destino)` / cambio de escena                    |
| Fin del guion    | nodo con `"fin": true` → `_finalizar_partida()`            |

**Tareas obligatorias** (además de reescribir el JSON):

1. `scripts/jugador.gd` → **invulnerabilidad temporal** con parpadeo tras perder una vida.
2. `scripts/main.gd` → **acelerar la formación** a medida que quedan menos invasores.
3. `scripts/enemigo.gd` → definir y justificar el comportamiento al chocarte.
4. **Mecánica ligada a tu narrativa** (ludonarrativa): usá el patrón ya
   cableado en el template — una bandera del guion que modifique el juego
   (el ejemplo es `doble_canon`: dispara en triple). Tu diseño define **qué
   bandera, qué mecánica y en qué momento** se desbloquea.
5. Pantalla de inicio y de fin coherentes con tu historia (título y mensaje
   salen de los nodos `fin`).

**Opcionales (bonus):** efecto máquina de escribir en el diálogo
(`dialogo_ui.gd`), condiciones compuestas con `and`/`or` en `_cumple()`,
sonido/pixel art propio, indicador de récord en pantalla, dificultad
creciente dentro de cada oleada.

### E4 · Testing y playtest

1. **Corrida automática:** `godot --headless --path . --script res://tests/recorrer_juego.gd`
   tiene que terminar en `OK`. Si agregaste nodos y el test no los cubre,
   extendelo (es código de prueba: también se versiona).
2. **Checklist de calidad** (10 ítems de la guía, respondé Sí/No con evidencia):
   - ¿La premisa se explica en dos frases y sin adjetivos vacíos?
   - ¿Cada beat de la estructura tiene su contraparte jugable?
   - ¿Cada personaje tiene deseo, arco y una voz identificable?
   - ¿Cada opción produce un cambio medible de estado?
   - ¿Las ramas convergen o hay presupuesto para sostenerlas?
   - ¿La recompensa del juego coincide con el tema de la historia?
   - ¿Se lee cómodo mientras se juega (frases cortas, sin bloqueos)?
   - ¿Está versionado, con IDs estables y condiciones declaradas?
   - ¿Alguien que no escribió el guion puede implementarlo sin preguntar?
   - ¿Alguien que no lo escribió lo entendió al jugarlo?
3. **Playtest con 3 jugadores distintos.** Preguntá esto (nunca «¿te gustó?»):
   - _¿Qué pasó, según vos?_ → detecta pistas ilegibles.
   - _¿Por qué tomaste esa decisión?_ → detecta opciones sin intención.
   - _¿Qué esperabas que pasara?_ → detecta promesas incumplidas.
4. **Reporte de 1 página:** qué falló, qué cambiaste después de jugar y por qué.

---

## 6. Estructura de la entrega

```
tu-carpeta/
├── docs/
│   ├── diseno_narrativo.md      # E1 (premisa, tema, mundo, personajes, beats, grafo)
│   └── playtest.md              # E4 (checklist + reporte)
├── guion/
│   └── capitulo_1.json          # E2 (tu historia)
├── escenas/  scripts/           # E3 (template completado)
└── README.md                    # cómo abrirlo, qué hace, qué implementaste
```

Reglas:

- El template modificado **debe correr sin errores** en el editor (F5).
- Todo el texto visible del juego en **español**.
- Commits con mensajes claros (`guion: agrego decisión del midpoint`,
  `main: acelero formación al quedar pocos`), uno por avance funcional.
- La IA se usa como asistente (explicar código, comparar enfoques): **el que
  entrega es el que entiende** — en la defensa tenés que poder explicar
  cualquier línea.

---

## 7. Cronograma sugerido (3 clases)

| Clase | Trabajo                                                                                         |
| ----- | ----------------------------------------------------------------------------------------------- |
| 1     | Leer el template y el guion de ejemplo · cerrar **E1** (diseño de 1 a 6)                |
| 2     | Escribir **E2** (JSON con tus nodos) · implementar tareas **E3** 1 a 3             |
| 3     | Mecánica narrativa (E3.4-5) · **E4** (test automático + playtest + reporte) · entrega |

---

## 8. Rúbrica (100 puntos)

| Ítem                          | Puntos | Se evalúa                                                                                                               |
| ------------------------------ | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| **E1** Diseño narrativo | 20     | Premisa accionable, tema discutible, beat sheet mapeado a oleadas, grafo con convergencia y costo                        |
| **E2** Guion JSON        | 20     | ≥8 nodos, 2 decisiones con `cond`+`efecto`, 3 finales alcanzables, sin falsas ilusiónes de elección, IDs estables |
| **E3** Implementación   | 25     | Juego corriendo sin errores, 3 tareas obligatorias, máquina de estados clara y legible                                  |
| Ludonarrativa                  | 15     | Al menos una mecánica desbloqueada por una decisión del guion, coherente con el tema                                   |
| **E4** Testing           | 15     | Corrida automática en OK, checklist respondida, playtest con 3 jugadores y cambios aplicados                            |
| Código limpio y Git           | 5      | Nombres con intención, funciones cortas, sin código muerto, commits ordenados                                          |

**No aprobado con:** guion sin decisión real (todo lleva al mismo final), el
juego no arranca, o entrega sin documentos de diseño.

---

## 9. Referencias

- _Creación de guiones para Juegos_ — clase teórica (proceso en 8 pasos,
  ramificación, formato tabular, checklist de calidad).
- _Godot — Pasos Iniciales_ y _Godot — Material de Apoyo_ (material de la
  materia): nodos, escenas, señales, GDScript, flujos de desarrollo.
- Tutorial oficial _Your first 2D game_: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html
- Documentación Godot 4: https://docs.godotengine.org/en/stable/
- Guion de ejemplo comentado: `template/guion/capitulo_1.json`
