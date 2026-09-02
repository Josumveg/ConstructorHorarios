#include <stdio.h>
#include "cJSON.h"
#include "../include/carga.h"

/*
 * Modulo: Estructuras, constantes y carga de archivos
 * Responsable: Jose
 *
 * Formato de entrada: JSON (catalogo.json, historial.json), parseado con
 * cJSON (vendorizada en lib/cjson/, ver lib/cjson/README.md). Ver
 * data/README.md para el esquema acordado por el equipo.
 *
 * TODO (Jose):
 *   - Definir el esquema JSON exacto (nombres de campos, anidamiento de
 *     grupos/bloques/requisitos) y documentarlo en data/README.md.
 *   - Implementar la carga: leer el archivo completo a un buffer (usar
 *     MAX_TAMANO_JSON de constantes.h), llamar cJSON_Parse(), recorrer el
 *     arbol resultante con cJSON_GetObjectItemCaseSensitive() /
 *     cJSON_ArrayForEach() y llenar catalogo->cursos[] / historial->aprobados[].
 *     Manejar errores de archivo/formato (archivo faltante, JSON invalido,
 *     campos faltantes, etc.) y liberar el arbol con cJSON_Delete() al final.
 *   - Decidir si liberar_catalogo/liberar_historial necesitan hacer algo
 *     real (los structs actuales usan arreglos estaticos) o si solo
 *     reinician los contadores/campos.
 */

int cargar_catalogo(const char *ruta, Catalogo *catalogo) {
    if (ruta == NULL || catalogo == NULL) {
        return ERROR_ARCHIVO;
    }

    /* TODO: leer el archivo JSON completo, parsear cada curso y llenar catalogo->cursos[] */
    catalogo->cantidad_cursos = 0;

    return EXITO;
}

int cargar_historial(const char *ruta, Historial *historial) {
    if (ruta == NULL || historial == NULL) {
        return ERROR_ARCHIVO;
    }

    /* TODO: leer el archivo JSON y llenar historial->aprobados[] */
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
