# data/

Archivos de entrada y salida de la etapa 2. Los tres son **JSON**, igual que
en la etapa 1. Los nombres de campo del JSON coinciden con los de la etapa 1
(`codigo`, `creditos`, `numero_grupo`, `hora_inicio`...) para que quien venga
de [`etapa1-c/data/data_doc.md`](../../etapa1-c/data/data_doc.md) no tenga que
aprender nombres nuevos.

| Archivo | Rol | Quien lo produce |
|---|---|---|
| `catalogo_salida.json` | Entrada. Salida de la etapa 1 (C) con el campo nuevo `carrera`. | `etapa1-c` (se copia aqui) |
| `preferencias.json` | Entrada. Cursos y grupos de interes y rango de creditos. | El estudiante (a mano) |
| `combinaciones.json` | Salida. Contrato con la etapa 3 (Prolog). | `main.rkt` |

> **Estado de `catalogo_salida.json`:** la copia que hay hoy en el repo es
> la salida de la etapa 1 sobre el catalogo de 4 semestres, **sin** el campo
> `carrera`. Se reemplaza cuando el equipo termine los 6 semestres y el
> cambio en C (ver
> [`../distribucion-tareas-etapa2-cemestre.md`](../distribucion-tareas-etapa2-cemestre.md),
> seccion 4). `lectura.rkt` acepta ambas versiones.

## `catalogo_salida.json` (entrada)

Mismo esquema que la salida de la etapa 1 (ver su `data_doc.md`), con un campo
nuevo por curso:

```jsonc
{
  "cursos": [
    {
      "codigo": "CE1106",
      "nombre": "Paradigmas de Programación",
      "creditos": 3,
      "carrera": "Ingeniería en Computadores",      // NUEVO, obligatorio
      "carreras": ["Ingeniería en Computadores"],     // igual que en la etapa 1
      "requisitos": ["CE2103"],
      "correquisitos": [],
      "grupos": [
        { "numero_grupo": 1,
          "bloques": [ { "dia": "K", "hora_inicio": 1700, "hora_fin": 1850 } ] }
      ],
      "choca_con_otro": true,
      "matriculable": true
    }
  ],
  "ciclos": [],
  "hay_ciclos": false
}
```

Esta etapa **solo lee** `codigo`, `creditos`, `carrera`, `grupos` y
`matriculable`; el resto del JSON se ignora.

| Campo | Notas para esta etapa |
|---|---|
| `carrera` | **Nuevo.** Carrera que *aporta* el curso: una sola por curso. Para un curso compartido por las dos carreras (ej. `MA1102`) es la carrera del plan del que se tomaron sus datos (la misma que ya se eligió curso por curso para los requisitos en conflicto). Si falta, `lectura.rkt` usa el primer elemento de `carreras`. |
| `matriculable` | Solo los cursos con `true` ("habilitados") pueden entrar a una combinación. Ya viene calculado, esta etapa no recalcula requisitos. |
| `choca_con_otro` | **Se ignora.** Está a nivel de curso y es `true` para los 45 cursos; esta etapa recalcula choques entre grupos concretos. |
| `dia` | `"L"`, `"K"` (martes), `"M"` (miércoles), `"J"`, `"V"`, `"S"`. Se convierte a símbolo (`'M`) al leer. |

## `preferencias.json` (entrada)

```jsonc
{
  "creditos_min": 9,
  "creditos_max": 12,
  "intereses": [
    { "codigo": "CE1106", "grupos": [1, 2] },
    { "codigo": "CI1106", "grupos": [1, 2, 3] }
  ]
}
```

| Campo | Tipo | Notas |
|---|---|---|
| `creditos_min`, `creditos_max` | entero | Rango deseado, **ambos extremos incluidos**. |
| `intereses` | arreglo | Cursos que el estudiante quiere considerar. |
| `intereses[].codigo` | string | Un `codigo` del catálogo. |
| `intereses[].grupos` | arreglo de enteros | Números de grupo de interés. El enunciado pide que el archivo de ejemplo incluya **más de un grupo** por curso. |

Un curso de `intereses` solo entra a las combinaciones si además es
`matriculable` y le queda al menos un grupo de interés que exista en el
catálogo. Si no, se ignora.

## `combinaciones.json` (salida)

```jsonc
{
  "combinaciones": [
    {
      "selecciones": [
        { "curso": "CE1106", "grupo": 1, "carrera": "Ingeniería en Computadores",
          "creditos": 3,
          "bloques": [
            { "dia": "K", "hora_inicio": 1700, "hora_fin": 1850 },
            { "dia": "J", "hora_inicio": 1700, "hora_fin": 1850 }
          ] }
      ],
      "creditos_totales": 3
    }
  ]
}
```

Campos que exige el enunciado:

| Campo | Qué es |
|---|---|
| `selecciones[].curso` + `selecciones[].grupo` | Lista de pares curso-grupo seleccionados. |
| `creditos_totales` | Suma de los créditos de los cursos de la combinación. |
| `selecciones[].carrera` | Carrera de origen de cada curso incluido. |

Campos extra (justificados en el README, sección 2.3):

| Campo | Por qué |
|---|---|
| `selecciones[].creditos` | Créditos del curso. Con solo el total y la carrera, Prolog no podría sumar créditos por carrera. |
| `selecciones[].bloques` | Días y horas del grupo (mismo formato que el catálogo; `dia` como string). Permite a Prolog aplicar reglas de horario sin releer el catálogo. |

Esta etapa no se vuelve a modificar después de entregarla y Prolog lee solo
este archivo, por eso estos dos datos se incluyen desde ya. No se agregó
ningún otro campo. Si ninguna combinación cumple, el archivo igual es JSON
válido: `{ "combinaciones": [] }`.
