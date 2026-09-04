# data/

Carpeta para los archivos de entrada y salida del programa. Los 3 archivos
usan **JSON**. Los nombres de campos en el JSON son **idénticos** a los
nombres de los campos en los `struct` de
[`include/estructuras.h`](../include/estructuras.h), a propósito: así el
código de parseo/serialización con cJSON es un mapeo directo campo-por-campo,
sin necesidad de traducir nombres.

## `catalogo.json` (entrada)

Catálogo de cursos recolectado de la Guía de Horarios y el plan de estudios
del TEC (ver sección 4 de
[../distribucion-tareas-etapa1-cemestre.md](../distribucion-tareas-etapa1-cemestre.md)).
Cubre **solo los primeros 4 semestres** de las 2 carreras del grupo
(Ingeniería en Computadores + Ingeniería en Producción Industrial), todos los
cursos de ambas carreras van en el mismo arreglo `cursos`.

```jsonc
{
  "cursos": [
    {
      "codigo": "CE1101",
      "nombre": "Introducción a la Programación",
      "creditos": 3,
      "carreras": ["Ingeniería en Computadores"],
      "requisitos": [],
      "correquisitos": [],
      "grupos": [
        {
          "numero_grupo": 1,
          "bloques": [
            { "dia": "M", "hora_inicio": 730, "hora_fin": 920 },
            { "dia": "V", "hora_inicio": 730, "hora_fin": 920 }
          ]
        },
        {
          "numero_grupo": 2,
          "bloques": [
            { "dia": "M", "hora_inicio": 1500, "hora_fin": 1650 },
            { "dia": "V", "hora_inicio": 1500, "hora_fin": 1650 }
          ]
        }
      ]
    },
    {
      "codigo": "MA1102",
      "nombre": "Cálculo Diferencial e Integral",
      "creditos": 4,
      "carreras": ["Ingeniería en Computadores", "Ingeniería en Producción Industrial"],
      "requisitos": ["MA0101"],
      "correquisitos": [],
      "grupos": []
    }
  ]
}
```

### Campos de cada curso

| Campo JSON | Tipo JSON | Campo en `struct Curso` | Notas |
|---|---|---|---|
| `codigo` | string | `codigo` | Ej. `"CE1101"`. Debe ser único en el catálogo — es la clave que usan `requisitos`/`correquisitos`/`aprobados` para referenciar cursos. |
| `nombre` | string | `nombre` | Tal como aparece en la Guía de Horarios/plan de estudios. |
| `creditos` | number (entero) | `creditos` | |
| `carreras` | array de strings | `carreras[]` / `cantidad_carreras` | Casi siempre un solo elemento. Si un curso es compartido entre las 2 carreras (ej. `MA1102`, `QU1102`, `FI1201` — cursos generales que ambos planes comparten), se listan ambas en vez de duplicar la entrada del curso. |
| `requisitos` | array de strings | `requisitos[]` / `cantidad_requisitos` | Lista de `codigo` de otros cursos. Arreglo vacío `[]` si no tiene. Si un requisito queda fuera del catálogo (ej. `MA0101`, Bloque 0 / nivelación, no cubierto por este proyecto), documentarlo como caso límite en el README de `etapa1-c/` — no se puede validar automáticamente. |
| `correquisitos` | array de strings | `correquisitos[]` / `cantidad_correquisitos` | Mismo formato que `requisitos`. |
| `grupos` | array de objetos `Grupo` | `grupos[]` / `cantidad_grupos` | Arreglo vacío `[]` si todavía no se tiene el horario de ese curso (dato pendiente de recolectar). |

### Campos de cada grupo (`Grupo`)

| Campo JSON | Tipo JSON | Campo en `struct Grupo` | Notas |
|---|---|---|---|
| `numero_grupo` | number (entero) | `numero_grupo` | Ej. `1`, `2`. |
| `bloques` | array de objetos `BloqueHorario` | `bloques[]` / `cantidad_bloques` | Uno por cada franja horaria del grupo (ej. un curso con teoría lunes/miércoles tiene 2 bloques). |

### Campos de cada bloque horario (`BloqueHorario`)

| Campo JSON | Tipo JSON | Campo en `struct BloqueHorario` | Notas |
|---|---|---|---|
| `dia` | string de 1 carácter | `dia` (`char`) | Uno de `"L"`, `"K"`, `"M"`, `"J"`, `"V"`, `"S"` (Lunes, Martes, Miércoles, Jueves, Viernes, Sábado — se usa `K` para martes porque `M` ya es miércoles, convención de `estructuras.h`). Al parsear con cJSON se toma `valuestring[0]`. |
| `hora_inicio` | number (entero, formato `HHMM`) | `hora_inicio` | Ej. `730` = 7:30, `1500` = 15:00. La Guía de Horarios usa `HH:MM` (ej. `"07:30-09:20"`) — hay que convertir a este formato entero al transcribir. |
| `hora_fin` | number (entero, formato `HHMM`) | `hora_fin` | Igual que `hora_inicio`. |

## `historial.json` (entrada)

Lista de cursos ya aprobados por un estudiante de prueba (usa los mismos
`codigo` que aparecen en `catalogo.json`):

```json
{
  "aprobados": ["CE1101", "CE1104", "MA1102", "MA1403"]
}
```

| Campo JSON | Tipo JSON | Campo en `struct Historial` |
|---|---|---|
| `aprobados` | array de strings | `aprobados[]` / `cantidad_aprobados` |

## `catalogo_salida.json` (salida)

Mismo esquema que `catalogo.json`, más los 2 campos que calcula el programa
(`choca_con_otro` y `matriculable` — los 8 campos mínimos del enunciado en
total: código, nombre, créditos, grupos/horarios, requisitos, correquisitos,
choque, matriculable). `carreras` es un campo extra, no exigido por el
enunciado — se justifica porque el catálogo mezcla 2 carreras en un solo
archivo (ver sección 2.2 del README de `etapa1-c/`, "información agregada
al esquema, justificada"):

```jsonc
{
  "cursos": [
    {
      "codigo": "CE1101",
      "nombre": "Introducción a la Programación",
      "creditos": 3,
      "carreras": ["Ingeniería en Computadores"],
      "requisitos": [],
      "correquisitos": [],
      "grupos": [ /* igual formato que en catalogo.json */ ],
      "choca_con_otro": false,
      "matriculable": true
    }
  ]
}
```

| Campo JSON | Tipo JSON | Campo en `struct Curso` | Notas |
|---|---|---|---|
| `choca_con_otro` | boolean | `choca_con_otro` (`int` 0/1) | JSON boolean nativo (`true`/`false`), más claro para quien consuma el archivo en la etapa de Racket. En C, `cJSON_IsTrue()`/`cJSON_CreateBool()` hacen el mapeo a/desde el `int` del struct. |
| `matriculable` | boolean | `matriculable` (`int` 0/1) | Igual que `choca_con_otro`. |

## Parseo/serialización

Se usa **cJSON** (vendorizada en [`../lib/cjson/`](../lib/cjson/README.md)),
no un parser propio — ver la justificación en ese README.

## Estado de los datos

- **`catalogo.json`**: **45 cursos**, primeros 4 semestres de las 2
  carreras — 29 de Ingeniería en Computadores y 16 exclusivos de
  Ingeniería en Producción Industrial (más 14 cursos compartidos entre
  ambas, marcados con las 2 carreras en `carreras`). Todos con
  código/nombre/créditos/requisitos/correquisitos reales. Cada curso
  tiene **como máximo 5 grupos** — límite de diseño del equipo
  (`MAX_GRUPOS` no se subió más allá de 10); en los cursos que en la
  realidad tienen más secciones abiertas (algunos como `FI1201` llegan a
  25), se eligieron 5 al azar.
  - **Los 45 cursos tienen horario real** (`grupos` con datos) — catálogo
    completo, campus Cartago, ambas carreras.
- **`historial.json`**: 25 cursos aprobados de un estudiante real de
  prueba (Jose), extraídos de su propio Expediente Estudiantil. Son
  todos de Computadores — falta un historial de prueba para un
  estudiante de Producción Industrial si el equipo lo necesita.

### Conflictos entre planes (resueltos)

Al cruzar los datos de las 2 carreras, 3 cursos compartidos tenían
**requisitos/correquisitos distintos** según el plan de estudios de cada
carrera. El equipo decidió, curso por curso, cuál de las 2 versiones usar
(no es un promedio ni una unión, es una elección explícita):

| Curso | Versión Computadores | Versión Producción Industrial | Se usó |
|---|---|---|---|
| `FI1101` | Requisitos: `MA1102` / Correquisitos: ninguno | Requisitos: ninguno / Correquisitos: `MA1102` | **Computadores** |
| `CS2101` | Requisitos: ninguno | Requisitos: `CI1107` | **Producción Industrial** |
| `FI1102` | Requisitos: `FI1101` / Correquisitos: `MA1102` | Requisitos: `FI1101, FI1201, MA1102` / Correquisitos: `FI1202` | **Computadores** |

### Casos límite encontrados (para la sección de README del enunciado)

- **`MA0101` es Bloque 0 para Computadores pero Bloque 1 real para
  Producción Industrial:** `MA1102` (Computadores) tiene como requisito
  `MA0101`, que en el plan de Computadores es Bloque 0 / nivelación
  (fuera de "primeros 4 semestres"). Al cargar Producción Industrial
  resultó que `MA0101` **sí** es un curso normal de su Bloque 1 — así que
  ya está en el catálogo con datos y horario reales, `carreras: ["Ingeniería en Producción Industrial"]`.
  Esto resuelve la referencia colgante que existía antes.
- **`CI1230` (Inglés I, Producción Industrial) requiere cursos fuera del
  catálogo:** `CI0200` y `CI0202` son cursos de nivelación de inglés que
  no aparecen en ninguno de los 2 planes de primeros 4 semestres — quedan
  como referencias sin resolver en `requisitos`, igual que pasaba con
  `MA0101` antes de encontrar sus datos reales.
- **La Guía de Horarios no expone un número de grupo oficial:** la tabla
  de TEC-Digital solo lista pares (profesor, horario) por curso, sin un
  campo "Grupo 01/02/03". Se le asignó `numero_grupo` secuencial (1, 2,
  3...) a cada combinación única de profesor+horario encontrada, ignorando
  la columna "Periodo" (I/II semestre del año) que tampoco forma parte del
  `struct Grupo`. Filas duplicadas (mismo profesor y horario en período I y
  II) se colapsaron en un solo grupo.
- **Cursos con más secciones de las que caben en `MAX_GRUPOS`:** algunos
  cursos de primer año (ej. `FI1201` con 25 secciones, `MA1102` con 22)
  tienen más grupos reales de los que el equipo decidió soportar (máximo
  5 por curso). En esos casos se tomó una muestra aleatoria de 5 grupos
  reales (no inventados) en vez de subir el límite — decisión del equipo
  para mantener el dataset manejable.
- **Los códigos de "actividad" del plan no siempre coinciden con los de
  la oferta real:** `SE1100`/`SE1200`/`SE1400` (Actividad Cultural/
  Deportiva) aparecen en el plan de estudios, pero la Guía de Horarios
  solo ofrece variantes específicas (`SE1101`-`SE1109` para actividades
  culturales — Artes dramáticas, Danza, Artes musicales, etc.; `SE1201`-
  `SE1222` para deportivas — Atletismo, Natación, Fútbol, etc.). Se
  resolvió así (confirmado con el equipo): los `grupos` de `SE1100` se
  tomaron de una muestra aleatoria de 5 secciones reales dentro del rango
  `SE11xx`, los de `SE1200` del rango `SE12xx`, y los de `SE1400`
  ("Actividad Cultural-Deportiva") de una muestra mixta de ambos rangos —
  para ese curso el estudiante puede elegir cualquier combinación de
  actividad cultural o deportiva.
- **`FH1000` tampoco es un código único en la oferta real:** "Centros de
  Formación Humanística" en la Guía de Horarios no aparece como `FH1000`,
  sino como ~54 cursos-seminario distintos con temas específicos (ej.
  `FH0204` "Hablemos de discapacidad", `FH0251` "El universo de Star
  Wars: entre la ciencia ficción, la política y la mitología") — el
  estudiante elige uno cualquiera para cumplir el requisito. Se resolvió
  igual que con los `SE`: los `grupos` de `FH1000` son una muestra
  aleatoria de 5 secciones reales entre las ~16 ofrecidas en el campus de
  Cartago.

Las rutas por defecto están en [`include/constantes.h`](../include/constantes.h).
