# CEmestre — Etapa 2 (Paradigma Funcional, Racket)
## Plan de trabajo y distribución de tareas

**Equipo:** Jose, Pablo, Javier, Sebastian (grupo de 4 → aplica el criterio adicional de **optimización por poda**; la etapa se califica sobre 115 puntos)

**Entrega:** último commit antes del **viernes 30 de octubre de 2026, 9:30 a.m.** El enlace del repositorio se entrega por el TEC-Digital. Valor de la etapa: 8 %.

---

## 1. Alcance de esta etapa

El programa en Racket debe:
1. Leer el catálogo que exporta la etapa 1 (**6 semestres** por carrera, no 4).
2. Leer un archivo de preferencias del estudiante: cursos y grupos de interés (más de un grupo por curso) y créditos mínimos y máximos.
3. Generar las combinaciones válidas de horario: un grupo por cada curso incluido, **sin choques** entre los grupos elegidos, usando **streams** (no se arma la lista completa).
4. Por ser grupo de 4: **descartar una combinación apenas se detecta un choque**, en vez de generarla completa y descartarla después (poda).
5. Filtrar las combinaciones por el rango de créditos.
6. Exportar las combinaciones a un archivo (**JSON**, ver `data/data_doc.md`) con los tres campos mínimos que pide el enunciado: pares curso-grupo, créditos totales y carrera de origen de cada curso. Es el contrato con la etapa 3 (Prolog).

Restricciones del enunciado que aplican a **todo** el código:
- **Cero mutación**: ni `set!`, ni estructuras mutables, ni variables globales reasignadas. El estado se maneja con recursión e inmutabilidad.
- **Tipado explícito**: contratos en todos los límites de módulo (ver README, decisión 1).
- **Al menos una función con polimorfismo paramétrico**, reutilizable para más de un tipo de filtro.
- **Ejecutable** para la revisión (`make exe`).

No debe: armar el horario final, sugerir combinaciones, optimizar por preferencias, tener interfaz, ni aplicar reglas más allá de créditos (eso es la etapa 3).

---

## 2. Estructuras de datos base (ya definidas en `src/tipos.rkt`)

Todas inmutables, exportadas con `contract-out`. Equivalen a `estructuras.h` de la etapa 1: **acordarlas juntos antes de programar**, porque los cuatro módulos trabajan contra este contrato.

| Struct | Campos | Quién la produce | Quién la consume |
|---|---|---|---|
| `bloque` | `dia` (símbolo `'L 'K 'M 'J 'V 'S`), `inicio`, `fin` (HHMM) | `lectura.rkt` | `choques.rkt`, `exportacion.rkt` |
| `grupo` | `numero`, `bloques` | `lectura.rkt` | todos |
| `curso` | `codigo creditos carreras grupos matriculable` | `lectura.rkt` | `candidatos.rkt`, `exportacion.rkt` |
| `catalogo` | `cursos` | `lectura.rkt` | `candidatos.rkt` |
| `interes` | `codigo`, `grupos` (enteros) | `lectura.rkt` | `candidatos.rkt` |
| `preferencias` | `intereses`, `creditos-min`, `creditos-max` | `lectura.rkt` | `candidatos.rkt`, `filtros.rkt`, `exportacion.rkt` |
| `opcion` | `curso`, `grupos` (los elegibles) | `candidatos.rkt` | `generacion.rkt` |
| `seleccion` | `curso`, `grupo` (un par elegido) | `generacion.rkt` | `exportacion.rkt` |
| `combinacion` | `selecciones`, `creditos-totales` | `generacion.rkt` | `filtros.rkt`, `exportacion.rkt` |

Flujo de datos entre módulos:

```
catalogo_salida.json ─┐
                      ├─ lectura ─► catalogo, preferencias
preferencias.json  ───┘                │
                                       ▼
                         candidatos ─► (listof opcion)
                                       │
                                       ▼
                         generacion ─► (stream combinacion)   ← usa choques
                                       │
                                       ▼
                         filtros ────► (stream combinacion)   ← solo las del rango
                                       │
                                       ▼
                         exportacion ─► combinaciones.json
```

---

## 3. Módulos, funciones y responsable

| # | Módulo | Archivos | Funciones principales | Responsable | Rubro relacionado |
|---|--------|----------|------------------------|-------------|--------------------|
| 1 | Tipos y lectura | `src/tipos.rkt`, `src/lectura.rkt` | structs y contratos, `leer-catalogo`, `leer-preferencias`, `jsexpr->curso` y compañía, validación y errores de formato | **Jose** | Uso de tipos/contratos (8) + lectura del catálogo (req. 1) |
| 2 | Choques y candidatos | `src/choques.rkt`, `src/candidatos.rkt` | `bloques-se-solapan?`, `grupos-chocan?`, `compatible-con-seleccion?`, `construir-opciones` | **Pablo** | Generación correcta sin choques (20, compartido con Javier) |
| 3 | Generación con streams y poda | `src/generacion.rkt` | `generar-combinaciones` (con poda), `armar-combinacion` | **Javier** | Streams (15) + Diseño funcional (12) + Poda de grupos de 4 (15) + Generación (20) |
| 4 | Filtros, polimorfismo y exportación | `src/filtros.rkt`, `src/exportacion.rkt` | `filtrar-flujo`, `por-rango`, `filtrar-por-creditos`, `combinacion->jsexpr`, `exportar-combinaciones` | **Sebastian** | Créditos (7) + Polimorfismo paramétrico (8) + formato de salida (README, 15) |

**Nota de carga:** el módulo 3 es el más difícil y el que más puntos mueve. Pablo (que escribe los choques de los que depende la poda) hace **pareja con Javier**, y además le corresponde el caso límite real del README (sección 2.2) sobre candidatos.

---

## 4. Datos y cambios en la etapa 1

El enunciado pide dos cosas sobre los datos: ampliar el plan de estudios a **6 semestres** (antes 4) y que cada curso indique su carrera. Lo segundo ya está resuelto: el campo `carreras` de la etapa 1 trae una carrera, o las dos si el curso es compartido. Lo primero se hace reutilizando el módulo de C con más datos, **sin tocar la lógica de choques ni de requisitos**.

### 4.1 Recolección de los semestres 5 y 6

**Responsable: Jose**, los cuatro bloques (a diferencia de la etapa 1, donde se repartió por semestre). Limpia y valida los datos (códigos, créditos, requisitos, correquisitos, horarios y `carreras`) y los integra a `etapa1-c/data/catalogo.json`:

| Carrera | Semestre |
|---|---|
| Ingeniería en Computadores | 5 |
| Ingeniería en Computadores | 6 |
| Ingeniería en Producción Industrial | 5 |
| Ingeniería en Producción Industrial | 6 |

Los semestres 5 y 6 traen requisitos hacia cursos de los semestres 1-4: revisar que cada código referenciado exista en el catálogo (si no, documentarlo como caso límite, igual que `CI1230` en la etapa 1).

### 4.2 Ajustes en C (solo si hacen falta)

| Cambio | Archivos | Responsable |
|---|---|---|
| Si el catálogo de 6 semestres no carga por tamaño, subir `MAX_TAMANO_JSON` (131 072 bytes; el catálogo de 45 cursos pesa 51 KB, `MAX_CURSOS` = 150 alcanza) | `etapa1-c/include/constantes.h` | Jose |
| Corregir solo los tests de C que fallen por tener más cursos (ej. los que cuentan los 45 cursos reales) | `etapa1-c/tests/` | Jose |

Al terminar, se regenera `etapa1-c` y se **copia** su salida a `etapa2-racket/data/catalogo_salida.json`.

---

## 5. Tareas compartidas por todo el equipo

No se asignan a una sola persona porque afectan la nota de todos, y porque en la defensa **se puede pedir modificar el programa en el momento** y cualquiera puede tener que explicar cualquier parte:

- **`main.rkt` / integración:** ya está conectado el flujo completo (leer → candidatos → generar → filtrar → exportar). Falta probarlo de punta a punta cuando los módulos estén listos, y el manejo de argumentos y errores generales.
- **Decisiones de diseño:** las que hacían falta ya están tomadas y justificadas en el README, sección 2.1. Solo se cambian si el profesor indica otra cosa.
- **README:** cada quien documenta su módulo (qué hace, decisiones de diseño, casos límite, estructuras de datos); arquitectura general y el caso límite compartido en conjunto. **Sin documentación la nota es 0.**
- **Repositorio:** commits de los 4 a lo largo de todo el proyecto, en ramas propias, integrados a `develop` por pull request (ver README, sección "Flujo de trabajo"). Se evalúa cantidad de commits significativos y orden.
- **Pruebas:** cada quien hace pasar la suite de su módulo en `tests/` y agrega casos con datos reales.
- **Defensa:** revisión cruzada de código antes de la entrega; cada integrante debe poder explicar cualquier función, incluida la parte de otro.
- **Ejecutable:** `make exe` debe funcionar en la máquina que se lleve a la revisión. Si el código no compila la nota es 0: probar `make test` antes de cada merge a `develop`.

---

## 6. Cronograma (actualizado al 20 de octubre → 30 de octubre)

| Fechas | Meta |
|---|---|
| 20–23 oct | Todos los módulos con su suite de `tests/` pasando en su rama. Datos de los semestres 5 y 6 terminados (Jose). Consultar al profesor la interpretación de "combinación" y de `carreras` (README, decisiones 2 y 7). |
| 24–27 oct | Integración en `develop`: catálogo de 6 semestres copiado a `data/`, `main.rkt` de punta a punta, caso límite real documentado. Primer `make exe`. |
| 28–30 oct | Redacción final del README, revisión cruzada de código, ensayo de la defensa. **Último commit antes del viernes 30 a las 9:30 a.m.** |

---|---|
| 1 (8–14 oct) | Acordar en conjunto los structs de `tipos.rkt` y el formato de entrada/salida (`data/data_doc.md`). Consultar al profesor la interpretación de "combinación" (README, decisión 2). Iniciar recolección de los semestres 5 y 6. |
| 2 (15–21 oct) | Cada quien programa su módulo y hace pasar su suite de `tests/`. Datos de 6 semestres terminados. |
| 3 (22–27 oct) | Integración en `main.rkt`, pruebas con el catálogo completo de 6 semestres, caso límite real. Primer `make exe`. |
| 4 (28–30 oct) | Redacción final del README, revisión cruzada de código, ensayo de la defensa. **Último commit antes del viernes 30 a las 9:30 a.m.** |

---

## 7. Checklist final de entregables

- [ ] Structs con contratos en `tipos.rkt`, todos inmutables
- [ ] Catálogo de 6 semestres por carrera con `carreras` en cada curso, y `etapa1-c` regenerada y copiada a `data/`
- [ ] `preferencias.json` de ejemplo con más de un grupo por curso
- [ ] Lectura de catálogo y preferencias sin errores, con mensajes claros ante archivos faltantes o mal formados
- [ ] Combinaciones generadas **con streams** (sin `stream->list` en el flujo principal)
- [ ] Combinaciones sin choques, descartadas con **poda** (apenas se detecta el choque)
- [ ] Filtro por rango de créditos, con extremos incluidos
- [ ] Al menos una función con **polimorfismo paramétrico**, usada con más de un tipo
- [ ] Cero `set!`, cero estructuras mutables, cero variables globales reasignadas (`grep -rn "set!" src main.rkt` vacío)
- [ ] Exportación con los campos mínimos (pares curso-grupo, créditos totales, carrera de origen)
- [ ] README con arquitectura, decisiones de diseño (2.2.1), un caso límite real (2.2.2), justificación del formato de salida ligada a una decisión real (2.2.3) y estructuras de datos (2.3)
- [ ] Repositorio con commits de los 4 integrantes
- [ ] Ejecutable funcional (`make exe`) y equipo para la revisión
