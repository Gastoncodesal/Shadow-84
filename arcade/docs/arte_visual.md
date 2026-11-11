# SHADOW//84 — Dirección artística y balance final

## Identidad visual

Paleta: azul noche/cian en las azoteas, ámbar cobre/ocre en la Forja, fucsia/púrpura en la Ciudadela y rojo coral en el Núcleo. **Ren** dispone de seis cuadros de animación (respiración, pasos y ataque). Los soldados cibernéticos usan tres diseños diferenciados y animación alternada. **Raiden** tiene un modelo original de armadura con seis cuadros repartidos en tres fases. Los shurikens rotan y las balas hostiles emplean tres paletas de color. Cada enemigo destruido genera un estallido de partículas; Ren y el jefe producen impactos visuales al recibir daño.

Los fondos fueron creados para este proyecto y contienen arquitecturas, carteles, profundidad, líneas de perspectiva y edificios diferenciados; la lluvia se anima en Godot por encima de cada escenario. Los escenarios cambian al alcanzar las escenas narrativas y oleadas correspondientes.

| Tramo | Escenario | Función narrativa |
| --- | --- | --- |
| Introducción y oleada 1 | Azoteas de Neo-Kyoto | Regreso de Ren a la ciudad |
| Intermedio 1 y oleada 2 | Distrito de la Forja | Tecnología y producción militar de Kurogane |
| Intermedio 2 y oleada 3 | Ciudadela | Pasado del clan y acceso al núcleo |
| Antes del jefe y combate | Núcleo | Debate final con Raiden y combate decisivo |

## Ajustes de dificultad

| Enemigos | Formación | Resistencia | Cadencia hostil media | Tipo de presión |
| --- | --- | --- | --- | --- |
| Oleada 1 | 3 × 6 | 1 impacto | ~2,25 s | Reconocimiento, primera evasión |
| Oleada 2 | 3 × 7 | 1–2 impactos | ~1,48 s | Más vida y puntería |
| Oleada 3 | 4 × 8 | 2–3 impactos | ~1,02 s | Mayor velocidad y disparos dobles |
| Jefe Raiden | 1 jefe | 96 impactos | 1,55 / 1,10 / 0,79 s | Tres fases, patrones de abanico y ataques dirigidos |

La formación acelera al disminuir el número de enemigos. Si llega al refugio, la partida termina. Raiden es obligatorio para desbloquear el epílogo. Su barra indica vida restante y fase. El jugador obtiene 1,75 s de invulnerabilidad tras ser alcanzado.

**Duración objetivo**: 7–12 minutos según precisión, habilidad, cantidad de vidas perdidas y tiempo dedicado a leer diálogos. **No es una medición real**: debe validarse con playtests.

## Controles de audio

La esquina superior derecha contiene barra de volumen y botón ♪/×. También funciona la tecla `M`. El volumen se guarda en `user://audio.cfg` y sobrevive al reinicio. El audio ambiental original vive en `audio/ambiente.wav`.

## Recursos

Se utilizaron sprites PNG generados para este proyecto, sin imágenes ni personajes de franquicias externas. Los cuadros están en `template/recursos/`. El script de generación se distribuye en el nivel superior como `herramientas/create_art.py` para permitir modificaciones.
