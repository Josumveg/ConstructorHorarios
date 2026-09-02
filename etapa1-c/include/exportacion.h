#ifndef EXPORTACION_H
#define EXPORTACION_H

#include "estructuras.h"
#include "requisitos.h"

/*
 * Modulo: Formato de salida, exportacion y ciclos
 * Responsable: Sebastian
 * Rubro: Formato de salida (9) + Ciclos (15, extra por grupo de 4)
 */

/* Exporta el catalogo completo (con los 8 campos minimos requeridos) a
 * 'ruta_salida', en formato JSON (formato acordado por el equipo para los
 * 3 archivos del contrato: catalogo, historial y salida).
 * Retorna EXITO o un codigo de error definido en constantes.h. */
int exportar_catalogo(const Catalogo *catalogo, const char *ruta_salida);

/* DFS clasico para deteccion de ciclos sobre 'grafo', partiendo de 'nodo'.
 * 'visitados' y 'en_pila' deben tener tamano grafo->cantidad_nodos.
 * Retorna 1 si se encuentra un ciclo alcanzable desde 'nodo'. */
int dfs_detectar_ciclo(const GrafoRequisitos *grafo, int nodo,
                        int *visitados, int *en_pila);

/* Recorre todo el grafo de requisitos del catalogo (construido por Javier
 * en requisitos.c) y reporta si existen ciclos, incluyendo los cursos
 * involucrados. Retorna 1 si se detecto al menos un ciclo, 0 si no. */
int detectar_ciclos(Catalogo *catalogo);

#endif /* EXPORTACION_H */
