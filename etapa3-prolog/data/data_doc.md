# data/

Archivos de entrada y salida de la etapa 3. Los datos van en **JSON**, igual
que en las etapas 1 y 2, salvo la política, que es un archivo de **hechos de
Prolog** porque el enunciado pide "los parámetros como hechos".

| Archivo | Rol | Quién lo produce |
|---|---|---|
| `combinaciones.json` | Entrada. Salida de la etapa 2 (Racket) con el campo nuevo `area` por selección. | `etapa2-racket` (se copia aquí) |
| `politica.pl` | Entrada. Parámetros de las tres reglas como hechos. | El equipo (a mano) |
| `resultados.json` | Salida. Contrato con la etapa 4 (Java). | `main.pl` |

> **Estado de `combinaciones.json`:** la copia que hay hoy en el repo es un
> **ejemplo escrito a mano** con 5 combinaciones (una cumple, cuatro
> incumplen, ver `tests/ejemplos.pl`). Se reemplaza por la salida real de
> Racket cuando se termine la extensión de las etapas 1 y 2 (ver
> [`../distribucion-tareas-etapa3-cemestre.md`](../distribucion-tareas-etapa3-cemestre.md),
> sección 4).

## `combinaciones.json` (entrada)

Es la salida de la etapa 2 (ver su `data_doc.md`) más `area` en cada
selección. Esta etapa **solo lee** `curso`, `grupo`, `creditos`, `carreras` y
`area`; `bloques` y `creditos_totales` se ignoran.

```jsonc
{
  "combinaciones": [
    {
      "creditos_totales": 6,
      "selecciones": [
        { "curso": "CE1106", "grupo": 1,
          "carreras": ["Ingeniería en Computadores"],   // una carrera, o las dos si es compartido
          "creditos": 3,
          "area": "computacion",                         // campo nuevo de la etapa 3
          "bloques": [ { "dia": "K", "hora_inicio": 1700, "hora_fin": 1850 } ] }
      ]
    }
  ]
}
```

Las áreas válidas son: `matematica`, `fisica_quimica`, `computacion`,
`electronica`, `industrial` y `humanidades` (criterio en el README, decisión 2).

Un curso sin `area` es un error de formato: la carga debe decir cuál falta.

## `politica.pl` (entrada)

Hechos de Prolog. Se carga con `cargar_politica/1`. Los valores se pueden
modificar en la defensa sin tocar el código.

| Hecho | Significado |
|---|---|
| `max_porcentaje_carrera(Carrera, Porcentaje)` | Regla 1. Porcentaje máximo de los créditos totales de una combinación que puede aportar la carrera. Uno por carrera. |
| `max_cursos_area(N)` | Regla 2. Máximo de cursos de una misma área. |
| `par_incompatible(A, B)` | Regla 3. Dos cursos que no pueden ir juntos. Se declara en un solo sentido; la simetría la resuelve `incompatibles/2`. |
| `orden_reglas(Lista)` | Orden en que se revisan las reglas: la razón de rechazo es la primera de la lista que se viola. Nombres: `balance_carreras`, `limite_area`, `incompatibilidad`. |

## `resultados.json` (salida)

```jsonc
{
  "combinaciones": [
    {
      "id": 3,
      "selecciones": [
        { "curso": "CE1106", "grupo": 2 },
        { "curso": "QU1106", "grupo": 1 },
        { "curso": "FI1101", "grupo": 1 },
        { "curso": "FI1201", "grupo": 1 }
      ],
      "cumple": false,
      "razon": "limite_area",
      "cursos_a_quitar": ["FI1201"]
    }
  ]
}
```

Campos que exige el enunciado:

| Campo | Qué es |
|---|---|
| `selecciones[].curso` + `selecciones[].grupo` | Lista de pares curso-grupo de la combinación. |
| `cumple` | `true` si cumple las tres reglas, `false` si no. |
| `razon` | Primera regla violada (`"balance_carreras"`, `"limite_area"` o `"incompatibilidad"`); `null` si cumple. |

Campos agregados (justificados en el README, sección 2.2.3):

| Campo | Por qué |
|---|---|
| `id` | Posición de la combinación en el archivo de Racket (desde 1). Java puede cruzar el resultado con esa combinación, que sí trae bloques y créditos, sin que esta etapa los repita. |
| `cursos_a_quitar` | Criterio de grupos de 4: códigos de los cursos que, quitados de uno en uno, dejan la combinación cumpliendo todas las reglas. `[]` si cumple o si ninguno la arregla por sí solo. |

Si no hay combinaciones, el archivo igual es JSON válido:
`{ "combinaciones": [] }`.
