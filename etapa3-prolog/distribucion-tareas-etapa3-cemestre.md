# CEmestre — Etapa 3 (Paradigma Lógico, Prolog)
## Plan de trabajo y distribución de tareas

**Equipo:** Jose, Pablo, Javier, Sebastian (grupo de 4 → aplica el criterio adicional de **curso a quitar**; la etapa se califica sobre 115 puntos)

**Entrega:** último commit antes del **sábado 21 de noviembre de 2026, 9:30 a.m.** El enlace del repositorio se entrega por el TEC-Digital. Valor de la etapa: 8 %.

---

## 1. Alcance de esta etapa

El programa en Prolog debe:
1. Cargar las combinaciones que exporta la etapa 2 (Racket), que ahora traen el campo `area` por curso, y el archivo de política (hechos).
2. Evaluar cada combinación contra tres reglas: balance entre carreras, límite por área e incompatibilidad.
3. Indicar si la combinación cumple y, si no, **la primera regla que viola** (usando corte y/o negación por falla; el orden de las reglas es parte del diseño).
4. Tener al menos un predicado **usable en más de un modo** de consulta.
5. Recorrer todas las combinaciones por backtracking y **exportar** el resultado (JSON, ver `data/data_doc.md`): pares curso-grupo, `cumple` y `razon`. Es el contrato con la etapa 4 (Java).
6. Por ser grupo de 4: para cada combinación rechazada, calcular **qué curso podría quitarse** para que cumpla todas las reglas, **reutilizando los mismos predicados de validación** (sin duplicar la lógica).
7. Extender el proyecto: **8 semestres** por carrera (antes 6) y el campo **`area`** en C, propagado por Racket, sin modificar la lógica ya construida.

Restricciones del enunciado que aplican a **todo** el código:
- **Sin `assert`/`retract` ni variables globales** para resultados intermedios. Solo se permite `assertz` para **cargar los datos de entrada** (`carga.pl`). El estado viaja en argumentos y unificación.
- **Ejecutable con `swipl`** desde la línea de comandos (`swipl main.pl`).
- Los parámetros de la política salen de los **hechos**: ningún número ni par de cursos escrito en las reglas, porque se pueden cambiar en la defensa.

No debe: generar combinaciones nuevas, volver a filtrar por créditos ni presentar resultados en una interfaz.

---

## 2. Estructuras de datos base (ya definidas en `src/modelo.pl`)

Equivalen a `tipos.rkt` de la etapa 2: **acordarlas juntos antes de programar**, porque los módulos trabajan contra este contrato.

| Término | Forma | Quién lo produce | Quién lo consume |
|---|---|---|---|
| `curso` | `curso(Codigo, Grupo, Creditos, Carreras, Area)` | `carga.pl` | `reglas.pl`, `sugerencia.pl`, `exportacion.pl` |
| `combinacion` | `combinacion(Id, Cursos)` (hecho dinámico, solo para la carga) | `carga.pl` | `evaluacion.pl` |
| `resultado` | `resultado(Id, Cursos, Cumple, Razon, CursosAQuitar)` | `evaluacion.pl` | `exportacion.pl` |
| hechos de política | `max_porcentaje_carrera/2`, `max_cursos_area/1`, `par_incompatible/2`, `orden_reglas/1` | `data/politica.pl` | `reglas.pl`, `razon.pl` |

Flujo de datos entre módulos:

```
combinaciones.json ─┐
                    ├─ carga ─► hechos combinacion/2 + hechos de política
politica.pl  ───────┘                │
                                     ▼
                        evaluacion (recorre por backtracking)
                          │  por cada combinacion:
                          ├─► razon ───────► reglas   (primera regla violada)
                          └─► sugerencia ──► razon    (curso a quitar, reutiliza cumple/1)
                                     │
                                     ▼
                        exportacion ─► resultados.json
```

---

## 3. Módulos, funciones y responsable

| # | Módulo | Archivos | Predicados principales | Responsable | Rubro relacionado |
|---|--------|----------|-------------------------|-------------|--------------------|
| 1 | Modelo y carga | `src/modelo.pl`, `src/carga.pl` | términos `curso/5` y `combinacion/2`, `cargar_politica`, `cargar_combinaciones`, `json_a_curso`, errores de formato | **Jose** | Modelado de datos y carga (10) |
| 2 | Reglas de política | `src/reglas.pl` | `viola_balance`, `viola_area`, `viola_incompatibilidad`, `viola/2`, `creditos_carrera/3`, `incompatibles/2` | **Pablo** | Reglas de política correctas (24) + Predicado usable en más de un modo (6) |
| 3 | Razón de rechazo y curso a quitar | `src/razon.pl`, `src/sugerencia.pl` | `primera_violacion/2,3`, `cumple/1`, `evaluar/2`, `cursos_a_quitar/2` | **Javier** | Razón de rechazo (14) + Curso a quitar, grupos de 4 (15) |
| 4 | Recorrido, exportación y política | `src/evaluacion.pl`, `src/exportacion.pl`, `data/politica.pl` | `evaluar_combinacion`, `evaluar_todas`, `resultado_a_dict`, `exportar_resultados`, pares incompatibles | **Sebastian** | Exportación del resultado (10) + req. funcional 6 (recorrido por backtracking) |
| 5 | Extensión de las etapas 1 y 2 | `etapa1-c/`, `etapa2-racket/` (ver sección 4) | campo `area`, 8 semestres, propagación por Racket | **Jose** | Extensión del proyecto (6) |

**Nota de carga:** las reglas (módulo 2) son el criterio que más puntos mueve pero cada predicado es corto; Javier hace el diseño más delicado (corte y negación por falla) y el criterio extra de grupos de 4, que depende de que `cumple/1` y las reglas funcionen, así que **Javier y Pablo se coordinan desde el primer día**. Jose carga con la recolección de datos de los semestres 7 y 8 (igual que en la etapa 2) y por eso su módulo de Prolog es el más corto; Sebastian, además de su módulo, revisa los pares incompatibles contra el catálogo final (sección 4.4) y es quien mantiene `main.pl` y el `Makefile`.

---

## 4. Extensión de las etapas 1 y 2 (Jose)

El enunciado pide dos cosas: ampliar el plan a **8 semestres** por carrera y agregar el campo **área**, que "se agrega en C y se propaga por Racket". **No se modifica la lógica ya construida** (choques, requisitos, generación, filtros): solo se agregan datos y un campo.

### 4.1 Criterio para asignar el área

El área se asigna **por disciplina del contenido del curso**, con un conjunto fijo de 6 áreas. En la práctica casi siempre coincide con el prefijo del código (el departamento que lo dicta), y se documentan las excepciones. Así el criterio es reproducible para los semestres 7 y 8.

| Área (valor en el JSON) | Cursos | Ejemplos del catálogo |
|---|---|---|
| `matematica` | Prefijos `MA`, `CM` y los de Probabilidad y Estadística | `MA1102` Cálculo, `MA1403` Matemática Discreta, `CM3207` Métodos Numéricos, `PI2610` Probabilidad y Estadística I |
| `fisica_quimica` | Prefijos `FI`, `QU`, `ME` | `FI1101` Física General I, `QU1107` Química Básica II, `ME2208` Ciencias de los Materiales |
| `computacion` | Prefijo `CA` y los `CE` de software y arquitectura; `PI` de informática | `CE1101` Intro. a la Programación, `CE3101` Bases de Datos, `CE4301` Arquitectura I, `CA2125` Elementos de Computación, `PI3407` Computación Industrial |
| `electronica` | Prefijo `EL` y los `CE` de circuitos y diseño digital | `EL2113` Circuitos en CC, `EL2207` Elementos Activos, `CE2201` Lab. de Circuitos, `CE1109` Circuitos Analógicos |
| `industrial` | Prefijos `PI`, `MI`, `SO` | `MI2101` Dibujo Técnico, `PI3501` Costos Industriales I, `PI3603` Inv. de Operaciones I, `SO4604` Seguridad y Salud Ocupacional |
| `humanidades` | Prefijos `CI`, `CS`, `SE`, `FH` | `CI1106` Comunicación Escrita, `CS3404` Seminario de Ética, `SE1100` Actividad Cultural I, `FH1000` Formación Humanística |

Excepciones al prefijo (las que ya aparecen en el catálogo de 6 semestres): `PI2609`, `PI2610` y `PI3612` (Probabilidad y Estadística) son `matematica` y no `industrial`; `PI3407` y `PI3403` (computación e información) son `computacion`; `CE2201`, `CE3201`, `CE1109` y `CE1110` (circuitos, diseño digital, señales) son `electronica` y no `computacion`.

Jose asigna el área de **los 66 cursos actuales** y de los nuevos, y deja la tabla final (con los ejemplos reales que use) para el README, sección 2.2.1.

### 4.2 Cambios en C (`etapa1-c/`)

| Cambio | Archivos |
|---|---|
| Constante `MAX_LONG_AREA` (24 alcanza para `fisica_quimica`). Revisar `MAX_CURSOS` (150 alcanza para ~90 cursos) y `MAX_TAMANO_JSON` (el catálogo de 66 cursos pesa 67 KB; con 8 semestres y `area` debería caber en los 131 072 bytes, y si no, subirlo) | `include/constantes.h` |
| Campo `char area[MAX_LONG_AREA]` en `Curso` | `include/estructuras.h` |
| Leer `area` del catálogo (obligatorio: si falta, `ERROR_FORMATO`) y escribirlo en la salida, validando que termine en `'\0'` igual que `carreras` | `src/carga.c`, `src/exportacion.c` |
| Documentar el campo `area` | `data/data_doc.md` |
| Corregir solo los tests que fallen por tener más cursos o por el campo nuevo | `tests/` |

**No se toca** `choques.c` ni `requisitos.c`.

### 4.3 Cambios en Racket (`etapa2-racket/`)

| Cambio | Archivos |
|---|---|
| Campo `area` (`string?`) en el struct `curso`, después de `carreras` | `src/tipos.rkt` |
| Leer `area` como campo obligatorio | `src/lectura.rkt` |
| Escribir `area` en cada selección de la exportación | `src/exportacion.rkt` |
| Actualizar los constructores de `curso` en los tests | `tests/ejemplos.rkt`, `tests/test-lectura.rkt` y los demás que armen un `curso` |
| Documentar el campo `area` en la salida (campo extra justificado: lo exige la etapa 3) | `data/data_doc.md`, `README.md` |

**No se toca** `candidatos.rkt`, `choques.rkt`, `generacion.rkt` ni `filtros.rkt`. `make test` de la etapa 2 debe seguir pasando.

### 4.4 Datos

1. **Jose** agrega los semestres 7 y 8 de Ingeniería en Computadores y de Ingeniería en Producción Industrial a `etapa1-c/data/catalogo.json` (limpia y valida códigos, créditos, requisitos, correquisitos, horarios y `carreras`; revisa que cada requisito exista en el catálogo, y si no, lo documenta como caso límite). Todos los cursos llevan `area`.
2. Se regenera la salida de `etapa1-c`, se **copia** a `etapa2-racket/data/catalogo_salida.json`, se corre Racket y se **copia** su `combinaciones.json` a `etapa3-prolog/data/combinaciones.json`. Si hace falta, se ajusta `etapa2-racket/data/preferencias.json` para que el resultado traiga combinaciones de las dos carreras.
3. **Sebastian** revisa los 4 pares incompatibles de `data/politica.pl` contra el catálogo final: cada par debe existir en el catálogo y su justificación entra al README (2.2.1). Se agregan pares si los semestres 7 y 8 traen duplicados entre planes. El enunciado pide **al menos dos pares** en los dos planes.

---

## 5. Tareas compartidas por todo el equipo

No se asignan a una sola persona porque afectan la nota de todos, y porque en la defensa **se puede pedir modificar el programa en el momento** (cambiar un parámetro de la política, el orden de las reglas, una regla) y cualquiera puede tener que explicar cualquier parte:

- **`main.pl` / integración:** ya está conectado el flujo completo (cargar → evaluar todas → exportar). Falta probarlo de punta a punta con la salida real de Racket cuando los módulos estén listos.
- **Decisiones de diseño:** las que hacían falta ya están tomadas y justificadas en el README, sección 2.2. Solo se cambian si el profesor indica otra cosa.
- **README:** cada quien documenta su módulo (qué hace, decisiones, casos límite, ejemplos de consulta); arquitectura, caso límite real y el caso donde el orden de las reglas cambia la razón, en conjunto. **Sin documentación la nota es 0.**
- **Repositorio:** commits de los 4 a lo largo de todo el proyecto, en ramas propias, integrados a `develop` por pull request. Se evalúa cantidad de commits significativos y orden.
- **Pruebas:** cada quien hace pasar la suite de su módulo en `tests/` (`make test`) y agrega casos con datos reales.
- **Defensa:** revisión cruzada de código antes de la entrega; cada integrante debe poder explicar cualquier predicado, incluido el de otro.
- **Ejecutable:** debe correr con `swipl` en la máquina que se lleve a la revisión. Si el código no compila la nota es 0: probar `make test` antes de cada merge a `develop`.
- **Sin `assert`/`retract`:** `grep -rn "assert\|retract" src main.pl` solo debe aparecer en `carga.pl`.

---

## 6. Cronograma (16 de noviembre → 21 de noviembre)

| Fechas | Meta |
|---|---|
| Lun 16 – mar 17 nov | Revisar y acordar `modelo.pl` y los formatos de `data/data_doc.md`. Correr `make` y reportar cualquier error de sintaxis del esqueleto (no se pudo compilar al armarlo). Jose inicia el campo `area` en C y los semestres 7 y 8. Los demás programan su módulo con los datos de ejemplo de `tests/ejemplos.pl`. |
| Mié 18 – jue 19 nov | Cada quien con su suite de `tests/` pasando en su rama. Extensión de C y Racket terminada; `combinaciones.json` real copiado a `data/` (Jose). Pares incompatibles revisados (Sebastian). |
| Vie 20 nov | Integración en `develop`, `main.pl` de punta a punta con los datos reales, caso límite real y caso del orden de reglas documentados. Redacción final del README, revisión cruzada, ensayo de la defensa. |
| Sáb 21 nov | **Último commit antes de las 9:30 a.m.** Solo correcciones menores. |

---

## 7. Checklist final de entregables

- [ ] Combinaciones y cursos representados con hechos y términos compuestos (`modelo.pl`)
- [ ] Carga de las combinaciones de Racket y de la política, con errores claros ante archivos faltantes o mal formados
- [ ] Catálogo de **8 semestres** por carrera con `area` en cada curso; `etapa1-c` y `etapa2-racket` regeneradas, con sus tests pasando
- [ ] Área justificada con ejemplos de los planes (README 2.2.1)
- [ ] Las tres reglas como predicados parametrizados por los hechos de política (nada escrito en el código)
- [ ] Al menos **dos pares incompatibles** declarados y justificados
- [ ] Razón de rechazo (primera regla violada) con corte y/o negación por falla, justificado
- [ ] Un caso documentado donde el orden de las reglas cambia la razón reportada
- [ ] Al menos un predicado usable en **más de un modo**, con ejemplos de ambos usos en el README
- [ ] Recorrido de todas las combinaciones por backtracking y exportación
- [ ] Formato de salida con los campos mínimos (pares curso-grupo, `cumple`, `razon`) y justificación del formato y de los campos agregados
- [ ] Por cada combinación rechazada, curso a quitar calculado reutilizando `cumple/1` (grupos de 4)
- [ ] Sin `assert`/`retract` fuera de `carga.pl`, sin variables globales para resultados intermedios
- [ ] README con arquitectura (2.1), decisiones de diseño (2.2.1), un caso límite real (2.2.2) y representación de datos y predicados con consultas en más de un modo (2.3)
- [ ] Repositorio con commits de los 4 integrantes
- [ ] Ejecutable con `swipl` y equipo para la revisión
