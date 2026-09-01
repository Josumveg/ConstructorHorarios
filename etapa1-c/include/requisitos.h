#ifndef REQUISITOS_H
#define REQUISITOS_H

#include "estructuras.h"

/*
 * Modulo: Requisitos y correquisitos
 * Responsable: Javier
 * Rubro: Requisitos/correquisitos (20)
 */

/* Grafo de requisitos: por cada curso (indice en Catalogo->cursos), guarda
 * los indices de los cursos que son requisito directo suyo. Es una lista
 * de adyacencia sobre arreglos estaticos, pensada para que Sebastian la
 * recorra con dfs_detectar_ciclo() en exportacion.h/.c.
 *
 * Esta es una propuesta de partida: ajustenla en equipo si necesitan
 * representar tambien los correquisitos dentro del mismo grafo. */
typedef struct {
    int adyacentes[MAX_CURSOS][MAX_REQ]; /* indices de cursos requisito, por curso */
    int cantidad_adyacentes[MAX_CURSOS]; /* cuantos requisitos tiene cada curso */
    int cantidad_nodos;                  /* = catalogo->cantidad_cursos */
} GrafoRequisitos;

/* Retorna 1 si el estudiante ya aprobo 'codigo_curso' segun 'historial'. */
int estudiante_aprobo(const Historial *historial, const char *codigo_curso);

/* Retorna 1 si el estudiante cumple todos los requisitos de 'curso'. */
int cumple_requisitos(const Curso *curso, const Historial *historial);

/* Retorna 1 si el estudiante cumple/matricula los correquisitos de 'curso'. */
int cumple_correquisitos(const Curso *curso, const Historial *historial);

/* Recorre el catalogo y marca curso->matriculable en cada Curso. */
void determinar_matriculable(Catalogo *catalogo, const Historial *historial);

/* Construye el grafo de requisitos a partir del catalogo, para que
 * exportacion.c lo use en la deteccion de ciclos. */
void construir_grafo_requisitos(const Catalogo *catalogo, GrafoRequisitos *grafo);

#endif /* REQUISITOS_H */
