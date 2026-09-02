# CEmestre — Etapa 1 (Paradigma Imperativo, C)
## Plan de trabajo y distribución de tareas

**Equipo:** Jose, Pablo, Javier, Sebastian (grupo de 4 → aplica el criterio adicional de detección de ciclos; la etapa se califica sobre 115 puntos)

**Entrega:** último commit antes del martes 22 de setiembre de 2026, 8:00 a.m.

---

## 1. Alcance de esta etapa

El programa en C debe:
1. Cargar el catálogo de cursos (2 carreras, primeros 4 semestres cada una).
2. Cargar el historial de cursos aprobados del estudiante.
3. Detectar choques de horario entre grupos/cursos.
4. Determinar si el estudiante puede matricular cada curso (requisitos + correquisitos).
5. Por ser grupo de 4: detectar ciclos en el grafo de requisitos mediante DFS.
6. Exportar el catálogo completo, con todos los campos requeridos, a un archivo de salida (formato a elección del grupo; **el equipo decidió JSON** tanto para la entrada como para la salida, ver `data/README.md`) que servirá de contrato para la etapa de Racket.

No debe armar horarios, optimizar según preferencias, ni tener interfaz: el resultado es únicamente un archivo.

---

## 2. Estructuras de datos base (acuérdenlas juntos antes de repartir el trabajo)

Definidas en un header común (`estructuras.h`) y constantes en un archivo aparte (`constantes.h`, es obligatorio que estén separadas):

```c
typedef struct {
    char dia;            // 'L','K','M','J','V','S'
    int hora_inicio;     // ej. 700 = 7:00
    int hora_fin;
} BloqueHorario;

typedef struct {
    int numero_grupo;
    BloqueHorario bloques[MAX_BLOQUES];
    int cantidad_bloques;
} Grupo;

typedef struct {
    char codigo[MAX_LONG_CODIGO];
    char nombre[MAX_LONG_NOMBRE];
    int creditos;
    Grupo grupos[MAX_GRUPOS];
    int cantidad_grupos;
    char requisitos[MAX_REQ][MAX_LONG_CODIGO];
    int cantidad_requisitos;
    char correquisitos[MAX_REQ][MAX_LONG_CODIGO];
    int cantidad_correquisitos;
    int choca_con_otro;   // 0/1
    int matriculable;     // 0/1
} Curso;

typedef struct {
    Curso cursos[MAX_CURSOS];
    int cantidad_cursos;
} Catalogo;

typedef struct {
    char aprobados[MAX_CURSOS][MAX_LONG_CODIGO];
    int cantidad_aprobados;
} Historial;
```

Esto es solo una propuesta de partida: revísenla en equipo antes de programar, para que los cuatro trabajen contra el mismo contrato de structs desde el primer commit.

---

## 3. Módulos, funciones y responsable

| # | Módulo | Funciones principales | Responsable | Rubro relacionado |
|---|--------|------------------------|-------------|--------------------|
| 1 | Estructuras, constantes y carga de archivos | `cargar_catalogo()`, `cargar_historial()`, parseo de JSON, manejo de errores de archivo/formato, `liberar_catalogo()`, `liberar_historial()` | **Jose** | Carga de datos (10) + Memoria/estructuras (15) |
| 2 | Choques de horario | `bloques_se_solapan()`, `grupos_chocan()`, `calcular_choques(Catalogo*)` | **Pablo** | Choques de horario (16) |
| 3 | Requisitos y correquisitos | `estudiante_aprobo()`, `cumple_requisitos()`, `cumple_correquisitos()`, `determinar_matriculable()`, construcción del grafo de requisitos (lista de adyacencia) | **Javier** | Requisitos/correquisitos (20) |
| 4 | Formato de salida, exportación y ciclos | Diseño del esquema JSON de salida y justificación de la decisión, `exportar_catalogo()`, `dfs_detectar_ciclo()`, `detectar_ciclos(Catalogo*)` (usa el grafo que construye Javier) | **Sebastian** | Formato de salida (9) + Ciclos (15, extra por grupo de 4) |

---

## 4. Recolección de datos (Guía de Horarios TEC)

Se necesitan los **primeros 4 semestres** de: Ingeniería en Computadores + una Licenciatura a elegir por el grupo. Se reparte por semestre para que nadie recolecte un plan completo solo:

| Carrera | Semestres | Responsable |
|---|---|---|
| Ingeniería en Computadores | 1 y 2 | Jose |
| Ingeniería en Computadores | 3 y 4 | Pablo |
| Licenciatura elegida | 1 y 2 | Javier |
| Licenciatura elegida | 3 y 4 | Sebastian |

Cada quien limpia y valida sus propios datos (códigos, créditos, requisitos, correquisitos, horarios) antes de integrarlos al archivo de entrada común. Acordar un solo formato de entrada desde el inicio evita reproceso.

---

## 5. Tareas compartidas por todo el equipo

No se asignan a una sola persona porque afectan la nota de todos, y porque en la defensa cualquiera puede tener que explicar cualquier parte del código:

- **`main.c` / integración:** conectar los 4 módulos en el flujo final (cargar → calcular choques → calcular matriculabilidad → detectar ciclos → exportar). Mejor hacerlo en conjunto una vez que cada módulo esté probado por separado.
- **Manejo de argumentos y errores generales:** que el programa no truene con archivos faltantes o mal formados.
- **README:** cada quien documenta su propio módulo (qué hace, decisiones de diseño, casos límite encontrados); la sección de arquitectura general se arma en conjunto.
- **Repositorio:** todos comitean regularmente en ramas propias (ej. `feature/carga`, `feature/choques`, `feature/requisitos`, `feature/exportacion-ciclos`) y se integran a `develop` conforme se van probando. `main` solo recibe el commit inicial y luego los merges desde `develop` ya verificados (ver sección "Flujo de trabajo" del README de `etapa1-c/`).
- **Pruebas:** cada quien prueba su módulo con datos reales de su carrera antes de integrar.
- **Defensa:** revisión cruzada de código entre los 4 antes de la entrega, para que cualquiera pueda explicar cualquier función.

---

## 6. Cronograma sugerido (hoy 31 de agosto → 22 de setiembre)

| Semana | Meta |
|---|---|
| 1 (1–7 set) | Definir structs y formato de entrada/salida en conjunto. Iniciar recolección de datos. |
| 2 (8–14 set) | Cada quien programa su módulo por separado, con datos de prueba propios. |
| 3 (15–19 set) | Integración de los 4 módulos en `main.c`, pruebas con el catálogo completo. |
| 4 (20–22 set) | Redacción final del README, revisión cruzada de código, ensayo de la defensa. Commit final antes del martes 22 a las 8:00 a.m. |

---

## 7. Checklist final de entregables

- [ ] Structs y constantes en archivos separados
- [ ] Carga de catálogo e historial sin errores
- [ ] Detección de choques de horario funcionando
- [ ] Validación de requisitos y correquisitos funcionando
- [ ] Detección de ciclos (DFS) funcionando y reportando los cursos involucrados
- [ ] Exportación del catálogo completo con los 8 campos mínimos requeridos
- [ ] README con arquitectura, decisiones de diseño (con ejemplos reales del dataset), un caso límite documentado, y justificación del formato de salida
- [ ] Repositorio con commits de los 4 integrantes a lo largo del proyecto
- [ ] Ejecutable funcional para la defensa
