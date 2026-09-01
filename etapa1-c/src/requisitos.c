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
 *   - Implementar construir_grafo_requisitos para que Sebastian pueda
 *     recorrerlo con DFS y detectar ciclos.
 */

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
    if (catalogo == NULL || grafo == NULL) {
        return;
    }

    /* TODO: por cada curso, ubicar el indice de cada requisito dentro del
     * catalogo y agregarlo a grafo->adyacentes[i] */
    grafo->cantidad_nodos = catalogo->cantidad_cursos;
}
