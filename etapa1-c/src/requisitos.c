#include <stdio.h>
#include <string.h>
#include "../include/requisitos.h"

/*
 * Modulo: Requisitos y correquisitos
 * Responsable: Javier
 *
 * TODO (Javier):
 *   - Implementar estudiante_aprobo buscando codigo_curso en historial->aprobados.
 *   - Implementar cumple_requisitos usando estudiante_aprobo sobre curso->requisitos.
 *   - Definir con el equipo la semantica de correquisitos (se matriculan a
 *     la vez, o basta con estar matriculable) e implementar cumple_correquisitos.
 *   - Implementar determinar_matriculable combinando requisitos + correquisitos
 *     (y posiblemente choca_con_otro, segun se acuerde con Pablo).
 */

/* Busca el indice de un curso dentro del catalogo por su codigo exacto.
 * Retorna el indice si lo encuentra, o -1 si no existe en el catalogo. */
static int buscar_indice_curso(const Catalogo *catalogo, const char *codigo) {
    int i;

    for (i = 0; i < catalogo->cantidad_cursos; i++) {
        if (strcmp(catalogo->cursos[i].codigo, codigo) == 0) {
            return i;
        }
    }

    return -1;
}

int estudiante_aprobo(const Historial *historial, const char *codigo_curso) {
    if (historial == NULL || codigo_curso == NULL) {
        return 0;
    }

    /* TODO: recorrer historial->aprobados buscando codigo_curso */
    return 0;
}

int cumple_requisitos(const Curso *curso, const Historial *historial) {
    if (curso == NULL || historial == NULL) {
        return 0;
    }

    /* TODO: verificar que estudiante_aprobo() sea true para cada requisito */
    return 0;
}

int cumple_correquisitos(const Curso *curso, const Historial *historial) {
    if (curso == NULL || historial == NULL) {
        return 0;
    }

    /* TODO: verificar correquisitos segun la semantica que acuerde el equipo */
    return 0;
}

void determinar_matriculable(Catalogo *catalogo, const Historial *historial) {
    if (catalogo == NULL || historial == NULL) {
        return;
    }

    /* TODO: recorrer catalogo->cursos y actualizar curso->matriculable */
}

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
