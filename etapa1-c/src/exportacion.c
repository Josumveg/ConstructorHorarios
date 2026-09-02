#include <stdio.h>
#include "cJSON.h"
#include "../include/exportacion.h"

/*
 * Modulo: Formato de salida, exportacion y ciclos
 * Responsable: Sebastian
 *
 * Formato de salida: JSON (decidido por el equipo, igual que los archivos
 * de entrada), serializado con cJSON (vendorizada en lib/cjson/, ver
 * lib/cjson/README.md). Documentar en el README la justificacion ligada a
 * una decision de diseno real (ver punto 2.2.3 del enunciado).
 *
 * TODO (Sebastian):
 *   - Definir el esquema JSON de salida (los 8 campos minimos por curso) y
 *     documentarlo en el README junto con la justificacion de usar JSON.
 *   - Implementar exportar_catalogo: armar el arbol con cJSON_CreateObject()
 *     / cJSON_CreateArray() / cJSON_AddItemToObject() a partir de
 *     catalogo->cursos[], convertirlo a texto con cJSON_Print() (o
 *     cJSON_PrintUnformatted() si el tamano del archivo importa), escribirlo
 *     a ruta_salida y liberar el arbol con cJSON_Delete().
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

    /* TODO: abrir ruta_salida y escribir catalogo->cursos como JSON */

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
