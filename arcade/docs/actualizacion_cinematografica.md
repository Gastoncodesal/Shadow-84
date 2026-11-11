# SHADOW//84 — Cambios de la edición cinematográfica 2.0

## Objetivo

Resolver las observaciones del último playtest informal: oleadas repetitivas, dificultad poco justa en la tercera etapa y presentación demasiado sencilla respecto al juego de referencia **TESLA_84**. La referencia se utiliza exclusivamente para estudiar **claridad, ritmo y dramatización**, sin copiar sus imágenes, código o música.

## Cambios visibles

1. **Menú** con título, ilustración de Ren, instrucciones y botón de inicio.
2. **Retratos ilustrados** propios de Ren, Aiko y Raiden; los textos se revelan progresivamente y pueden mostrarse completos con un clic.
3. **Placas de intermisión** en el inicio de cada capítulo y en el enfrentamiento contra el jefe.
4. **Fondos narrativos**: azoteas, forja, ciudadela y cámara del núcleo, con luces, partículas y transiciones de color.
5. **Feedback de batalla**: barra con enemigos restantes, combo de puntos, destellos de impacto, aviso de daño, animación de dash y mensajes breves de Aiko.
6. **Audio**: cuatro pistas ambientales distintas y cinco efectos originales (shuriken, impacto, daño, dash, jefe), con volumen y silencio persistentes.

## Diseño de dificultad

| Capítulo | Escuadrón 1 | Escuadrón 2 | Patrón | Amenazas |
|---|---|---|---|---|
| 1 | 12 enemigos | 10 enemigos | Formación, algunas oscilaciones finales | Lenta, vertical |
| 2 | 14 enemigos | 15 enemigos | Zigzag e incursiones individuales | Balas avisadas, disparos dobles ocasionales |
| 3 | 15 enemigos | 12 enemigos | Serpenteo y excursiones cortas hacia abajo | Ataques dirigidos anunciados, límite de cinco balas |
| Jefe | Raiden 72 HP | Tres fases | Movimiento lateral, abanicos telegráficos | Límite de nueve balas simultáneas |

**Notas:** cada capítulo conserva una oleada académica, pero la divide en dos escuadrones internos para variar el ritmo. Los movimientos de incursión son periódicos, no persiguen al jugador sin aviso. Si Ren queda con menos de tres vidas antes del segundo escuadrón del capítulo 3, recibe una vida extra. Los disparos enemigos se anticipan con avisos visibles y existe una esquiva con recarga.

## Conexión guion → mecánica

- Rescate: vida extra cuando corresponde.
- Arsenal: triple shuriken en vez de uno, implementado en `jugador.gd`.
- Proteger la red civil: Ren llega al jefe con ayuda defensiva.
- Infiltración silenciosa: Raiden comienza con una armadura reducida.
- Raiden debe caer antes de abrir `EPILOGO` y elegir uno de los finales.

## Riesgos a verificar en Godot

1. Que el menú inicie la historia con clic y Enter.
2. Que los retratos se vean durante las pausas narrativas, sin tapar elecciones.
3. Que no haya balas que dañen durante el anuncio de un escuadrón.
4. Que las placas desaparezcan al terminar su transición.
5. Que la salud de Raiden se adapte a la elección de sigilo.
6. Que el test automático de Godot concluya con OK y que el juego se pueda terminar manualmente.

**No se declara un playtest humano ni una prueba de ejecución con Godot en este entorno.**
