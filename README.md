# CEmestre — constructor de horarios

Sistema que ayuda a un estudiante del TEC a armar su horario de matrícula,
validando requisitos, correquisitos y choques de horario entre cursos. Se
construye a lo largo del semestre en 4 etapas, cada una en un paradigma y
lenguaje distinto, donde cada etapa lee el archivo que produjo la anterior.

**El sistema NO es un único ejecutable.** Cada etapa es un programa
independiente que lee y escribe archivos; el formato de salida de una etapa
es el contrato de entrada de la siguiente. Por eso el repositorio está
organizado en una carpeta por etapa/lenguaje.

## Etapas

| # | Carpeta | Lenguaje | Paradigma | Funcionalidad | Estado |
|---|---------|----------|-----------|----------------|--------|
| 1 | [`etapa1-c/`](etapa1-c/) | C | Imperativo | Construye el catálogo de cursos y calcula, para cada uno, si tiene choque de horario con otros y si el estudiante cumple sus prerrequisitos. | En progreso |
| 2 | [`etapa2-racket/`](etapa2-racket/) | Racket | Funcional | Genera y filtra combinaciones posibles de horario a partir del catálogo validado por la etapa 1. | Pendiente |
| 3 | [`etapa3-prolog/`](etapa3-prolog/) | Prolog | Lógico | Aplica reglas de restricción (créditos máximos, compatibilidades) sobre las combinaciones generadas por la etapa 2. | Pendiente |
| 4 | [`etapa4-java/`](etapa4-java/) | Java | Orientado a objetos | Integra el resultado final y lo presenta al usuario. | Pendiente |

## Equipo

Jose, Pablo, Javier, Sebastian.

## Etapa 1 (actual)

El trabajo activo está en [`etapa1-c/`](etapa1-c/README.md), incluyendo cómo
compilar y ejecutar, la estructura de módulos y responsables, y el
documento de distribución de tareas
([`etapa1-c/distribucion-tareas-etapa1-cemestre.md`](etapa1-c/distribucion-tareas-etapa1-cemestre.md)).

Entrega de la etapa 1: último commit antes del martes 22 de setiembre de
2026, 8:00 a.m.
