#include <stdio.h>
#include <string.h>
#include "../include/requisitos.h"

/*
 * Modulo: Requisitos y correquisitos
 * Responsable: Javier
 *
 * Determina si un estudiante puede matricular un curso del catálogo este semestre.
 * Compara los requisitos y correquisitos que requiere un curso contra la lista de cursos ya aprobados del historial. 
 * Además, construye el grafo de requisitos que exportacion.c recorre con DFS.
 *
 * Salidas:
 *   - El valor del campo matriculable (0/1) de cada curso del catálogo, escrito por determinar_matriculable(). 
 *   - Construye GrafoRequisitos mediante construir_grafo_requisitos(). 
 * 
 * Un correquisito se cumple si ya esta aprobado o si existe en el catálogo.
 * Un curso ya aprobado queda con matriculable = 0, mientras que un curso matriculable = 1 significa que el estudiante puede matricularlo este semestre.
 */

/* Busca el índice de un curso dentro del catálogo por su código exacto, y lo retorna.*/
static int buscar_indice_curso(const Catalogo *catalogo, const char *codigo) {
    int i;

    for (i = 0; i < catalogo->cantidad_cursos; i++) {
        if (strcmp(catalogo->cursos[i].codigo, codigo) == 0) {
            return i;
        }
    }

    return -1;
}

/* Recorre el historial comparando cada código aprobado con codigo_curso. Retorna 1 si el estudiante ya aprobó el curso o 0 si no lo encuentra */
int estudiante_aprobo(const Historial *historial, const char *codigo_curso) {
    int i;

    if (historial == NULL || codigo_curso == NULL) {
        return 0;
    }

    for (i = 0; i < historial->cantidad_aprobados; i++) {
        if (strcmp(historial->aprobados[i], codigo_curso) == 0) {
            return 1;
        }
    }

    return 0;
}

/* Recorre los requisitos del curso y verifica con estudiante_aprobo() que cada uno aparezca en el historial. 
 * Retorna 1 si todos estan aprobados o si el curso no tiene requisitos, y 0 si falta al menos un curso. */
int cumple_requisitos(const Curso *curso, const Historial *historial) {
    int i;

    if (curso == NULL || historial == NULL) {
        return 0;
    }

    for (i = 0; i < curso->cantidad_requisitos; i++) {
        if (!estudiante_aprobo(historial, curso->requisitos[i])) {
            return 0;
        }
    }

    return 1;
}

/* Recorre los correquisitos del curso. Cada uno se cumple si ya esta aprobado en el historial o si existe en el catálogo.
 * Retorna 1 si todos cumplen o si el curso no tiene correquisitos.
 * Retorna 0 si alguno no esta aprobado o no existe en el catálogo. */
int cumple_correquisitos(const Curso *curso, const Historial *historial, const Catalogo *catalogo) {
    int i;

    if (curso == NULL || historial == NULL || catalogo == NULL) {
        return 0;
    }

    for (i = 0; i < curso->cantidad_correquisitos; i++) {
        const char *codigo_correq = curso->correquisitos[i];

        /* ya aprobado o esta en el catálogo, y se podría matricular junto con 'curso' */
        if (estudiante_aprobo(historial, codigo_correq)) {
            continue;
        }
        if (buscar_indice_curso(catalogo, codigo_correq) == -1) {
            return 0;
        }
    }

    return 1;
}

/* Recorre el catálogo y escribe el campo matriculable de cada curso donde:
 * 1 si el curso todavía no esta aprobado y cumple sus requisitos y correquisitos, 
 * 0 en cualquier otro caso. Los cursos ya aprobados quedan en 0 porque no se vuelven a matricular. */
void determinar_matriculable(Catalogo *catalogo, const Historial *historial) {
    int i;

    if (catalogo == NULL || historial == NULL) {
        return;
    }

    for (i = 0; i < catalogo->cantidad_cursos; i++) {
        Curso *curso = &catalogo->cursos[i];

        if (estudiante_aprobo(historial, curso->codigo)) {
            curso->matriculable = 0;
            continue;
        }

        curso->matriculable = cumple_requisitos(curso, historial) && cumple_correquisitos(curso, historial, catalogo);
    }
}

/* Construye la lista de adyacencia del grafo de requisitos donde por cada curso
 * del catálogo traduce cada código de requisito al índice que ese curso ocupa dentro de catalogo->cursos[], y lo guarda como una arista. */
void construir_grafo_requisitos(const Catalogo *catalogo, GrafoRequisitos *grafo) {
    int cantidad_cursos;
    int i, j;

    if (catalogo == NULL || grafo == NULL) {
        return;
    }

    /* el catálogo no debe superar MAX_CURSOS, pero si pasara se recorta para no escribir fuera de los arreglos */
    cantidad_cursos = catalogo->cantidad_cursos;
    if (cantidad_cursos > MAX_CURSOS) {
        fprintf(stderr,
                "aviso: catalogo tiene %d cursos, se recorta a MAX_CURSOS (%d)\n",
                cantidad_cursos, MAX_CURSOS);
        cantidad_cursos = MAX_CURSOS;
    }
    grafo->cantidad_nodos = cantidad_cursos;

    for (i = 0; i < cantidad_cursos; i++) {
        const Curso *curso = &catalogo->cursos[i];
        int cantidad_requisitos = curso->cantidad_requisitos;

        grafo->cantidad_adyacentes[i] = 0;

        /* no escribir más de MAX_REQ aristas por nodo */
        if (cantidad_requisitos > MAX_REQ) {
            fprintf(stderr,
                    "aviso: curso %s tiene %d requisitos, se recorta a MAX_REQ (%d)\n",
                    curso->codigo, cantidad_requisitos, MAX_REQ);
            cantidad_requisitos = MAX_REQ;
        }

        for (j = 0; j < cantidad_requisitos; j++) {
            const char *codigo_req = curso->requisitos[j];
            int indice_req = buscar_indice_curso(catalogo, codigo_req);

            if (indice_req == -1) {
                /* requisito fuera del catálogo de cursos */
                fprintf(stderr,
                        "aviso: el curso %s tiene un requisito sin resolver "
                        "en el catalogo: %s\n",
                        curso->codigo, codigo_req);
                continue;
            }

            /* cantidad_adyacentes[i] apunta a la siguiente posicion libre, y se usa como indice, asi el arreglo queda sin espacio vacíos */
            grafo->adyacentes[i][grafo->cantidad_adyacentes[i]] = indice_req;
            grafo->cantidad_adyacentes[i]++;
        }
    }
}
