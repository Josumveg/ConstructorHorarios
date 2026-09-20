# CEmestre — Etapa 1 (Paradigma Imperativo, C)

> Parte 1 de 4 del proyecto [CEmestre](../README.md). Las demás etapas (Racket,
> Prolog, Java) viven en sus propias carpetas al nivel raíz del repositorio.

Programa en C que, a partir del catálogo de cursos de una carrera y el historial
de un estudiante, calcula choques de horario, determina qué cursos son
matriculables (requisitos/correquisitos), detecta ciclos en el grafo de
requisitos y exporta el catálogo completo a un archivo que sirve de contrato
para la siguiente etapa del proyecto (Racket).

La distribución de tareas y el cronograma del equipo están en
[distribucion-tareas-etapa1-cemestre.md](distribucion-tareas-etapa1-cemestre.md).

## Equipo

Jose, Pablo, Javier, Sebastian.

## Estructura del repositorio

```
.
├── include/
│   ├── constantes.h     # limites, codigos de error y rutas por defecto
│   ├── estructuras.h    # structs base: BloqueHorario, Grupo, Curso, Catalogo, Historial
│   ├── carga.h          # Modulo 1 (Jose): carga de catalogo/historial
│   ├── choques.h        # Modulo 2 (Pablo): choques de horario
│   ├── requisitos.h     # Modulo 3 (Javier): requisitos/correquisitos + grafo
│   └── exportacion.h    # Modulo 4 (Sebastian): exportacion + deteccion de ciclos
├── src/
│   ├── main.c           # integracion de los 4 modulos (tarea compartida)
│   ├── carga.c
│   ├── choques.c
│   ├── requisitos.c
│   └── exportacion.c
├── data/                # archivos de entrada (catalogo, historial) y salida — todos JSON
├── lib/cjson/           # cJSON vendorizada (parseo/serializacion de JSON), ver lib/cjson/README.md
├── Makefile
└── distribucion-tareas-etapa1-cemestre.md
```

Cada módulo tiene su header en `include/` y su implementación (por ahora con
`TODO`s) en `src/`, siguiendo la tabla de responsables de la sección 3 del
documento de distribución de tareas.

## Compilar y ejecutar

Requiere `gcc` y `make`.

> **Windows:** correr `make` desde **Git Bash** (no PowerShell ni cmd.exe). El
> Makefile usa comandos estilo Unix (`rm -rf`, `mkdir -p`); si `make` no
> encuentra un shell POSIX (`sh.exe`) en el PATH, cae de vuelta a `cmd.exe`,
> que no entiende esos comandos y falla con errores como
> `CreateProcess(NULL, rm -rf build bin, ...) failed`. Git Bash ya viene
> instalado junto con Git y resuelve esto sin tocar el Makefile.

```bash
make            # compila bin/cemestre
make run        # compila y ejecuta con las rutas por defecto de constantes.h
make clean      # borra los artefactos de compilacion (build/, bin/)
```

Rutas por defecto (ver `include/constantes.h`): `data/catalogo.json`,
`data/historial.json`, `data/catalogo_salida.json`. Los 3 son JSON. También
se pueden pasar como argumentos:

```bash
./bin/cemestre data/catalogo.json data/historial.json data/catalogo_salida.json
```

## Estado actual

Este commit inicial deja listas las estructuras compartidas
(`estructuras.h`, `constantes.h`), los headers y esqueletos de los 4
módulos, la integración en `main.c` y el sistema de build. La lógica de
cada módulo está pendiente de implementación (ver los `TODO` en cada
`.c`), según el responsable asignado.

Pendientes de equipo antes de programar en serio:

- Confirmar/ajustar los `struct` de `estructuras.h` y los límites de
  `constantes.h` según el dataset real.
- Ya se decidió que catálogo, historial y salida son **JSON**; falta
  acordar el esquema exacto de campos — ver [`data/README.md`](data/README.md).
- Ya se decidió usar **cJSON** (vendorizada en [`lib/cjson/`](lib/cjson/README.md))
  para parsear/serializar JSON en C, en vez de escribir un parser propio —
  ver la justificación en [`lib/cjson/README.md`](lib/cjson/README.md).

## Flujo de trabajo

- `main` solo recibe el commit inicial y, más adelante, los merges de
  `develop` ya verificados (build limpio y módulos probados). No se comitea
  directo a `main` en el día a día.
- `develop` es la rama de integración: todo el trabajo del día a día pasa
  por ahí.
- Cada quien trabaja en su rama de feature a partir de `develop`
  (`feature/carga`, `feature/choques`, `feature/requisitos`,
  `feature/exportacion-ciclos`) y la integra a `develop` conforme se prueba.
- `main.c` se completa en conjunto, en `develop`, una vez que cada módulo
  esté probado por separado.
- Cuando la etapa 1 esté completa y verificada en `develop`, se hace merge/push
  a `main` como entrega final.
- Más detalle de cronograma, checklist de entregables y recolección de
  datos en [distribucion-tareas-etapa1-cemestre.md](distribucion-tareas-etapa1-cemestre.md).

## Exportación y detección de ciclos — Sebastián

La exportación utiliza cJSON y conserva todos los cursos, carreras,
requisitos, correquisitos, grupos y bloques horarios. Los indicadores
choca_con_otro y matriculable se escriben como booleanos JSON.

Se eligió JSON porque representa directamente la estructura de cursos,
grupos y horarios, y permite que la etapa de Racket lea los datos sin
necesitar un formato de texto personalizado.

La detección de ciclos utiliza el grafo de requisitos construido por
el módulo de requisitos. Mediante DFS se mantienen los nodos visitados
y los que siguen en la pila activa. Una conexión hacia un nodo de esa
pila identifica un ciclo, cuyo recorrido se imprime con los códigos
de los cursos involucrados.

Se recorren todos los componentes del grafo. Los correquisitos no se
incluyen en esta detección, ya que pueden representar matrícula simultánea.

### Caso límite

CI1230 tiene los requisitos CI0200 y CI0202, que no están en el catálogo.
El constructor del grafo advierte y omite esas conexiones, pero la
exportación conserva ambos códigos. No se pueden detectar ciclos que
dependan de cursos ausentes del catálogo.

### Validación realizada

- Compilación del programa completo.
- Revisión del JSON exportado: 45 cursos y 206 grupos.
- Cadena sin ciclos y requisito compartido sin falsos positivos.
- Ciclo de tres cursos y autorrequisito.
- Ciclo en un componente separado.
- Llamada directa al DFS y limpieza de la pila activa.
- Catálogo vacío y argumento nulo.

Las pruebas de ciclos están en:
tests/exportacion-ciclos/test_exportacion.c

La validación completa de matriculabilidad queda pendiente de integrar
la implementación correspondiente del equipo.