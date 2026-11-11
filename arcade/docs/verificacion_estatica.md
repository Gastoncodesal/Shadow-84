# Verificación estática de SHADOW//84 — v1.1 equilibrada

**Entorno:** revisión de archivos fuera de Godot 4. No hay ejecutable de Godot instalado ni conexión externa en este entorno. La prueba del juego con F5 y las corridas del test GDScript deben realizarse en una computadora con Godot.

## Verificaciones realizadas

- **24 nodos del guion JSON** leídos correctamente; tres finales alcanzables en el grafo, considerando los puntos de pausa entre oleadas (entrada, ENTRE_01, ENTRE_02, JEFE_PREP y EPILOGO).
- **26 imágenes PNG** validadas como archivos íntegros.
- **Cinco archivos WAV**, incluyendo las cuatro pistas originales del nuevo recorrido.
- **55 rutas de recursos** referenciadas desde archivos .gd, .tscn y .godot encontradas en el proyecto.
- Presencia de los dos escuadrones de ciudadela, barra de jefe de 72 HP, señal de ataque, dash y controles de sonido comprobadas en los scripts.
- Integridad comprobada de la versión ZIP.

## Importante: pruebas aún no realizadas

La verificación anterior es **estática**, no garantiza que los scripts se compilen ni que la experiencia esté equilibrada. Se debe ejecutar desde `template/`:

```sh
godot --headless --path . --script res://tests/recorrer_juego.gd
```

Luego jugar el recorrido completo al menos dos veces, con decisiones narrativas diferentes, y completar el playtest con tres personas de `docs/playtest.md`.

No se afirma haber pasado el test automático ni completado playtests humanos.
