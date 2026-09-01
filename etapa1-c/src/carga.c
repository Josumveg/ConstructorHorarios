#include <stdio.h>
#include "../include/carga.h"

/*
 * Modulo: Estructuras, constantes y carga de archivos
 * Responsable: Jose
 *
 * TODO (Jose):
 *   - Definir y documentar el formato del archivo de entrada del catalogo
 *     (acordado en equipo, ver distribucion-tareas-etapa1-cemestre.md).
 *   - Implementar el parseo linea por linea con manejo de errores de
 *     archivo/formato (archivo faltante, linea mal formada, etc.).
 *   - Decidir si liberar_catalogo/liberar_historial necesitan hacer algo
 *     real (los structs actuales usan arreglos estaticos) o si solo
 *     reinician los contadores/campos.
 */

int cargar_catalogo(const char *ruta, Catalogo *catalogo) {
    if (ruta == NULL || catalogo == NULL) {
        return ERROR_ARCHIVO;
    }

    /* TODO: abrir el archivo, parsear cada curso y llenar catalogo->cursos[] */
    catalogo->cantidad_cursos = 0;

    return EXITO;
}

int cargar_historial(const char *ruta, Historial *historial) {
    if (ruta == NULL || historial == NULL) {
        return ERROR_ARCHIVO;
    }

    /* TODO: abrir el archivo y llenar historial->aprobados[] */
    historial->cantidad_aprobados = 0;

    return EXITO;
}

void liberar_catalogo(Catalogo *catalogo) {
    if (catalogo == NULL) {
        return;
    }
    /* TODO: liberar memoria dinamica si el diseno final la usa */
    catalogo->cantidad_cursos = 0;
}

void liberar_historial(Historial *historial) {
    if (historial == NULL) {
        return;
    }
    /* TODO: liberar memoria dinamica si el diseno final la usa */
    historial->cantidad_aprobados = 0;
}
