# SHADOW//84 — LA ÚLTIMA SOMBRA

**Arcade ninja cyberpunk en Godot 4 — trabajo práctico final de Introducción a la Programación.**

Versión **2.0 cinematográfica**. El proyecto continúa el template académico **NEÓN 84** y mantiene los requisitos de tres oleadas, movimiento lateral, shurikens, vidas, puntaje récord, guion JSON, decisiones con banderas, condiciones, convergencias y tres finales. Se han agregado un menú ilustrado, retratos, seis escuadrones agrupados en tres capítulos, fondos narrativos, jefe Raiden de tres fases, efectos de sonido y transiciones.

## Abrir y ejecutar

1. Instalar **Godot 4.x** (la misma versión que se usó para abrir la edición anterior).
2. Importar **`arcade/template/project.godot`** y esperar la importación de imágenes y sonidos.
3. Presionar **F5**; elegir **COMENZAR MISIÓN** o Enter.
4. Continuar y seleccionar opciones con el mouse. Se puede hacer clic en Continuar para revelar inmediatamente un diálogo y una segunda vez para avanzar.

## Controles

| Control | Acción |
|---|---|
| Flechas izquierda/derecha | Movimiento horizontal |
| Espacio / Enter | Lanzamiento de shurikens; mantener para disparar con enfriamiento |
| Shift | Dash invulnerable breve, recarga 4 segundos y dirección según último desplazamiento |
| M / botón ♪ | Silenciar y reactivar |
| Barra de volumen | Regular música y efectos |
| Enter en pantalla final | Reiniciar desde el menú |

## Historia y decisiones

Ren, último ninja del clan Kurohane, combate el régimen tecnológico de Kurogane en Neo-Kyoto. Aiko acompaña la infiltración, mientras Raiden intenta demostrar que la libertad causa caos.

- **Rescate / archivos** cambia las banderas narrativas y una opción de diálogo posterior.
- **Liberar prisioneros** entrega una vida extra; **recuperar arsenal** desbloquea triple shuriken.
- **Proteger civiles** entrega ayuda adicional antes de Raiden; **infiltrarse en sigilo** reduce su blindaje de 72 a 60 unidades de energía.
- Después del jefe se accede a **tres finales**: sacrificio, despertar o nuevo shogun.

## Capítulos y dificultad

| Tramo | Composición | Identidad jugable | Escenario |
|---|---|---|---|
| 1. Azoteas | 2 × 6 + 2 × 5 | Formación clásica, tiros separados y segunda ronda con patrullas oscilantes | Ciudad lluviosa |
| 2. La Forja | 2 × 7 + 3 × 5 | Unidades con movimiento lateral, entradas verticales y blindaje selectivo | Zona industrial |
| 3. Ciudadela | 3 × 5 + 2 × 6 | Patrullas serpentinas e incursiones anticipables; algunas unidades blindadas | Fortaleza Kurogane |
| 4. Núcleo | Raiden con 72 HP, o 60 si elegiste sigilo | Tres fases de abanicos y ataques anunciados; máximo nueve balas hostiles | Cámara del núcleo |

La dificultad no aumenta simplemente añadiendo más enemigos: hay descansos entre escuadrones, ataque telegráfico, dash y un refuerzo de vida si la Ciudadela te deja con pocas vidas. El juego no tiene cronómetro obligatorio: su duración real depende de las decisiones, la puntería y los reintentos.

## Arquitectura para la defensa oral

- `scripts/main.gd`: controlador de fases **MENU → HISTORIA → OLEADA → JEFE → FINAL**, audio y coordinación.
- `scripts/pantalla_inicio.gd`: portada interactiva diseñada mediante nodos Control.
- `scripts/jugador.gd`: movimiento, enfriamiento de shurikens, triple disparo y dash.
- `scripts/enemigo.gd`: resistencia, colisiones y patrones 0–3.
- `scripts/jefe.gd`: 72 HP, fases y patrones, avisos visuales.
- `scripts/guion_manager.gd`: carga de JSON, flags, condiciones, efectos y saltos.
- `scripts/dialogo_ui.gd`: retratos, escritura progresiva, botones de elección.
- `scripts/hud.gd`: barras, hit feedback, placas de capítulo, récord y final.
- `scripts/arte/`: dibujos, animaciones y atmósfera ambiental.
- `recursos/`: **sprites propios**, cuatro escenas, retratos y placas.
- `audio/`: pistas por capítulo y efectos de sonido originales sintetizados.

## Pruebas

Desde `arcade/template`, con Godot disponible:

```bash
godot --headless --path . --script res://tests/recorrer_juego.gd
```

El test recorre **menú, tres capítulos (seis escuadrones), jefe con sus tres fases, diálogos y un final**. Además se valida el grafo y la accesibilidad de los tres finales. El verificador de archivos puede ejecutarse sin Godot desde la raíz de `arcade/`:

```bash
python herramientas/verificar_entrega.py
```

**Limitación:** la verificación de archivos no sustituye al arranque real del motor ni a un playtest de personas. Registrar el resultado real del test en `../docs/playtest.md`. No declarar pruebas humanas realizadas antes de completarlas.
