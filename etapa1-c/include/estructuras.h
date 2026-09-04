#ifndef ESTRUCTURAS_H
#define ESTRUCTURAS_H

#include "constantes.h"

/*
 * Structs base del proyecto CEmestre - Etapa 1.
 *
 * Esta es la propuesta de partida acordada en distribucion-tareas-etapa1-cemestre.md.
 * Es el "contrato" contra el que trabajan los 4 modulos (carga, choques,
 * requisitos y exportacion/ciclos): si alguien necesita cambiar un campo,
 * se coordina con el equipo antes de modificar este archivo, porque afecta
 * a todos los demas modulos.
 */

/* Un bloque de horario dentro de un grupo (ej. lunes 7:00-9:00) */
typedef struct {
    char dia;            /* 'L','K','M','J','V','S' */
    int hora_inicio;     /* formato HHMM, ej. 700 = 7:00, 1330 = 13:30 */
    int hora_fin;
} BloqueHorario;

/* Un grupo especifico de un curso, con sus bloques de horario */
typedef struct {
    int numero_grupo;
    BloqueHorario bloques[MAX_BLOQUES];
    int cantidad_bloques;
} Grupo;

/* Un curso del catalogo, con sus grupos, requisitos y correquisitos */
typedef struct {
    char codigo[MAX_LONG_CODIGO];
    char nombre[MAX_LONG_NOMBRE];
    int creditos;

    /* Carreras a las que pertenece el curso. Casi siempre una sola, pero
     * un curso puede ser compartido entre las 2 carreras del catalogo
     * (ej. PI2609 lo imparte Produccion Industrial pero tambien esta en
     * el plan de Computadores) - por eso es un arreglo y no un solo campo,
     * para no duplicar la entrada del curso. */
    char carreras[MAX_CARRERAS][MAX_LONG_NOMBRE_CARRERA];
    int cantidad_carreras;

    Grupo grupos[MAX_GRUPOS];
    int cantidad_grupos;

    char requisitos[MAX_REQ][MAX_LONG_CODIGO];
    int cantidad_requisitos;

    char correquisitos[MAX_REQ][MAX_LONG_CODIGO];
    int cantidad_correquisitos;

    int choca_con_otro;   /* 0/1 - lo calcula el modulo de choques */
    int matriculable;     /* 0/1 - lo calcula el modulo de requisitos */
} Curso;

/* Catalogo completo de cursos cargado desde el archivo de entrada */
typedef struct {
    Curso cursos[MAX_CURSOS];
    int cantidad_cursos;
} Catalogo;

/* Historial de cursos ya aprobados por el estudiante */
typedef struct {
    char aprobados[MAX_CURSOS][MAX_LONG_CODIGO];
    int cantidad_aprobados;
} Historial;

#endif /* ESTRUCTURAS_H */
