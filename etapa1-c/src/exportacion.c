#include <stdio.h>
#include "../include/exportacion.h"

/*
 * Modulo: Formato de salida, exportacion y ciclos
 * Responsable: Sebastian
 *
 * TODO (Sebastian):
 *   - Elegir y justificar el formato de salida (JSON o CSV) en el README,
 *     con los 8 campos minimos requeridos por curso.
 *   - Implementar exportar_catalogo escribiendo el catalogo completo.
 *   - Implementar dfs_detectar_ciclo (DFS con pila de recursion / en_pila)
 *     sobre el GrafoRequisitos que construye Javier en requisitos.c.
 *   - Implementar detectar_ciclos recorriendo todos los nodos del grafo,
 *     reportando (por stdout o en el archivo de salida) los cursos
 *     involucrados en cada ciclo encontrado.
 */

int exportar_catalogo(const Catalogo *catalogo, const char *ruta_salida) {
    if (catalogo == NULL || ruta_salida == NULL) {
        return ERROR_ARCHIVO;
    }

    /* TODO: abrir ruta_salida y escribir catalogo->cursos en el formato elegido */

    return EXITO;
}

int dfs_detectar_ciclo(const GrafoRequisitos *grafo, int nodo,
                        int *visitados, int *en_pila) {
    if (grafo == NULL || visitados == NULL || en_pila == NULL) {
        return 0;
    }

    /* TODO: marcar visitados[nodo] y en_pila[nodo], recorrer
     * grafo->adyacentes[nodo] recursivamente y detectar backedges */
    return 0;
}

int detectar_ciclos(Catalogo *catalogo) {
    if (catalogo == NULL) {
        return 0;
    }

    /* TODO: construir_grafo_requisitos(catalogo, &grafo) y llamar
     * dfs_detectar_ciclo desde cada nodo no visitado */
    return 0;
}
