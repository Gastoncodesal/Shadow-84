# E1 — Diseño narrativo: SHADOW//84

## 1. Premisa
En Neo-Kyoto, año 2084, Ren, el último ninja Kurohane, debe sobrevivir a tres barreras de centinelas para alcanzar el núcleo de Kurogane. Al descubrir que su propio clan creó la tecnología de control, deberá elegir entre salvar a la población, destruir el sistema o gobernarlo.

**Promesa:** arcade de 7–12 minutos objetivo (a validar en pruebas), acción con tres oleadas y decisiones que afectan combate y epílogo. **Tono:** cyberpunk melancólico, apto para adolescentes. **Referencias:** NEÓN 84 (formación y ritmo arcade) y Space Invaders (lectura de amenazas por filas).

## 2. Tema
La libertad vale más que la seguridad impuesta, incluso cuando elegir implica perder poder. **Pregunta:** ¿puede Ren destruir la opresión sin reproducirla?

## 3. Mundo
Kurogane dirige Neo-Kyoto mediante el Protocolo Silencio; sus centinelas avanzan en formaciones automatizadas. El clan Kurohane inventó el núcleo para proteger a la ciudad, pero Kurogane convirtió su tecnología en control. Los shurikens electromagnéticos pueden neutralizar a los centinelas. El sistema requiere un operador en el núcleo.

**Cronología:** 2062: fundación del núcleo; 2071: Kurogane lo militariza; 2078: caída del clan; 2084: regreso de Ren.

**Glosario:** Neo-Kyoto: ciudad vigilada; Kurogane: corporación militar; Kurohane: clan ninja; Protocolo Silencio: control neuronal; Centinela: autómata de defensa; Núcleo: centro del sistema; Shuriken de pulso: proyectil de Ren.

## 4. Personajes
**Ren:** desea vengar al clan; necesita aprender a proteger sin dominar; teme repetir sus errores; arco de venganza a elección ética; voz austera. Antagonismo: Raiden y su propia herencia.

**Aiko:** desea liberar a los civiles; necesita reconocer el pasado del clan; teme perder a Ren; voz serena, frases cortas. Aliada fuera de pantalla.

**Raiden:** desea orden absoluto; necesita aceptar la autonomía ajena; teme el caos; voz fría y persuasiva. Antagonista fuera de pantalla.

## 5. Beat sheet
| Beat | Avance | Hecho y contraparte jugable |
|---|---:|---|
| Hook | 0–10 % | Aiko presenta Neo-Kyoto; el jugador decide qué rescatar |
| Incidente | 15 % | Los centinelas detectan a Ren; comienza oleada 1 |
| Giro 1 | 25 % | Raiden revela el origen del núcleo; elección de rescate o arsenal |
| Midpoint | 50 % | Oleada 2 y confesión de Aiko sobre el maestro |
| Giro 2 | 75 % | Elegir protección o sigilo; se activa última barrera |
| Clímax | 90 % | Superar oleada 3 y derrotar a Raiden en tres fases |
| Resolución | 100 % | Elección de uno de tres finales y marcador |

## 6. Grafo, convergencias y costo
`INTRO_DECISION → INTRO_CIVILES / INTRO_ARCHIVOS → INTRO_CONVERGE → OLEADA 1 → ENTRE_01_DECISION → ENTRE_01_RESCATE / ENTRE_01_ARSENAL / ENTRE_01_SECRETO (cond: archivos) → ENTRE_01_CONVERGE → OLEADA 2 → ENTRE_02_DECISION → ENTRE_02_PROTECCION / ENTRE_02_SIGILO → ENTRE_02_CONVERGE → OLEADA 3 → EPILOGO → tres finales`.

**Banderas:** `civiles`, `archivos`, `honor`, `conocimiento`, `prisioneros`, `arsenal`, `doble_canon`, `vida_extra`, `acceso_secreto`, `proteccion`, `sigilo`, `final_sacrificio`, `final_despertar`, `final_shogun`. Rescatar prisioneros suma una vida; recuperar arsenal activa triple shuriken. Las decisiones iniciales cambian estados y una opción posterior; las del epílogo cambian el desenlace. **Costo de ramas:** 2 nodos intro + 3 nodos intermedio + 2 nodos previo a clímax + 3 finales, todos breves y con convergencia.

## Extensión final: jefe narrativo y arte por beat

Tras la tercera oleada aparecen `JEFE_PREP` y `JEFE_ENTRADA`, que revelan que Raiden integra su cuerpo con el núcleo. El jugador debe derrotarlo antes de acceder a `EPILOGO`. El combate tiene 96 puntos de energía y tres fases que cambian el patrón de ataque. Esta batalla es la **contraparte jugable del clímax**, no un texto añadido después de la victoria. Cada intermedio cambia el escenario: azoteas → Forja → Ciudadela → Núcleo.
