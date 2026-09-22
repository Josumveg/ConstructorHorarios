#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cJSON.h"
#include "../include/carga.h"

/*
 * Modulo: Estructuras, constantes y carga de archivos
 * Responsable: Jose
 *
 * Formato de entrada: JSON (catalogo.json, historial.json), parseado con
 * cJSON (vendorizada en lib/cjson/, ver lib/cjson/README.md). El esquema
 * completo (nombres de campo, anidamiento de grupos/bloques) esta
 * documentado en data/data_doc.md; los nombres de campo del JSON son
 * identicos a los del struct, asi que el mapeo es directo.
 */

/* ---------------------------------------------------------------------
 * Helpers privados de este modulo (no van en carga.h porque nadie mas
 * los necesita).
 * --------------------------------------------------------------------- */

/* Lee todo el contenido de 'ruta' a un buffer nuevo terminado en '\0'.
 * El buffer se reserva con malloc y el llamador debe liberarlo con free().
 * Retorna NULL si el archivo no existe, esta vacio, o supera
 * MAX_TAMANO_JSON (para no reservar memoria sin limite con un archivo
 * corrupto o gigante). Se abre en modo binario ("rb") para que el tamano
 * que da ftell() coincida exacto con lo que se lee despues; en Windows,
 * el modo texto convierte saltos de linea y desalinea esa cuenta. */
static char *leer_archivo_completo(const char *ruta) {
    FILE *archivo = fopen(ruta, "rb");
    if (archivo == NULL) {
        return NULL;
    }

    fseek(archivo, 0, SEEK_END);
    long tamano = ftell(archivo);
    rewind(archivo);

    if (tamano <= 0 || tamano > MAX_TAMANO_JSON) {
        fclose(archivo);
        return NULL;
    }

    char *buffer = malloc((size_t)tamano + 1);
    if (buffer == NULL) {
        fclose(archivo);
        return NULL;
    }

    size_t leidos = fread(buffer, 1, (size_t)tamano, archivo);
    fclose(archivo);

    buffer[leidos] = '\0';
    return buffer;
}

/* Copia 'origen' a 'destino' sin desbordar el buffer. 'tamano_destino' es
 * el tamano total del buffer (incluyendo el espacio para el '\0'). */
static void copiar_seguro(char *destino, const char *origen, size_t tamano_destino) {
    strncpy(destino, origen, tamano_destino - 1);
    destino[tamano_destino - 1] = '\0';
}

/* Copia hasta 'limite' strings de 'array_json' a 'destino[i]' (cada uno de
 * MAX_LONG_CODIGO bytes). Se usa para requisitos, correquisitos y
 * aprobados: los tres son, en el fondo, "una lista de codigos de curso".
 * Si 'array_json' no existe o no es un arreglo, cJSON_ArrayForEach no
 * itera nada y 'cantidad' queda en 0 (no es un error: significa lista
 * vacia). Los elementos que no sean string se ignoran. */
static void cargar_lista_codigos(const cJSON *array_json, char destino[][MAX_LONG_CODIGO], int limite, int *cantidad) {
    const cJSON *item = NULL;

    *cantidad = 0;
    cJSON_ArrayForEach(item, array_json) {
        if (*cantidad >= limite) {
            break;
        }
        if (cJSON_IsString(item)) {
            copiar_seguro(destino[*cantidad], item->valuestring, MAX_LONG_CODIGO);
            (*cantidad)++;
        }
    }
}

/* Llena 'curso' a partir de un objeto JSON del arreglo "cursos". Retorna
 * EXITO o ERROR_FORMATO si le faltan los campos obligatorios (codigo,
 * nombre, creditos). */
static int cargar_curso(const cJSON *curso_json, Curso *curso) {
    const cJSON *codigo = cJSON_GetObjectItemCaseSensitive(curso_json, "codigo");
    const cJSON *nombre = cJSON_GetObjectItemCaseSensitive(curso_json, "nombre");
    const cJSON *creditos = cJSON_GetObjectItemCaseSensitive(curso_json, "creditos");

    if (!cJSON_IsString(codigo) || !cJSON_IsString(nombre) || !cJSON_IsNumber(creditos)) {
        return ERROR_FORMATO;
    }

    copiar_seguro(curso->codigo, codigo->valuestring, MAX_LONG_CODIGO);
    copiar_seguro(curso->nombre, nombre->valuestring, MAX_LONG_NOMBRE);
    curso->creditos = creditos->valueint;

    /* choca_con_otro y matriculable no vienen en el archivo de entrada:
     * los calculan los modulos de choques y requisitos mas adelante. Se
     * inicializan en 0 aqui para que el struct nunca quede con basura. */
    curso->choca_con_otro = 0;
    curso->matriculable = 0;

    /* carreras: arreglo corto (maximo MAX_CARRERAS), se copia igual que
     * requisitos/correquisitos pero con su propio tamano de string. */
    curso->cantidad_carreras = 0;
    const cJSON *carreras_json = cJSON_GetObjectItemCaseSensitive(curso_json, "carreras");
    const cJSON *carrera_item = NULL;
    cJSON_ArrayForEach(carrera_item, carreras_json) {
        if (curso->cantidad_carreras >= MAX_CARRERAS) {
            break;
        }
        if (cJSON_IsString(carrera_item)) {
            copiar_seguro(curso->carreras[curso->cantidad_carreras], carrera_item->valuestring, MAX_LONG_NOMBRE_CARRERA);
            curso->cantidad_carreras++;
        }
    }

    cargar_lista_codigos(cJSON_GetObjectItemCaseSensitive(curso_json, "requisitos"),
                          curso->requisitos, MAX_REQ, &curso->cantidad_requisitos);
    cargar_lista_codigos(cJSON_GetObjectItemCaseSensitive(curso_json, "correquisitos"),
                          curso->correquisitos, MAX_REQ, &curso->cantidad_correquisitos);

    /* grupos: cada uno tiene un numero y su propio arreglo de bloques de
     * horario, asi que se recorren en un doble ciclo. */
    curso->cantidad_grupos = 0;
    const cJSON *grupos_json = cJSON_GetObjectItemCaseSensitive(curso_json, "grupos");
    const cJSON *grupo_json = NULL;
    cJSON_ArrayForEach(grupo_json, grupos_json) {
        if (curso->cantidad_grupos >= MAX_GRUPOS) {
            break;
        }
        Grupo *grupo = &curso->grupos[curso->cantidad_grupos];

        const cJSON *numero_grupo = cJSON_GetObjectItemCaseSensitive(grupo_json, "numero_grupo");
        grupo->numero_grupo = cJSON_IsNumber(numero_grupo) ? numero_grupo->valueint : 0;

        grupo->cantidad_bloques = 0;
        const cJSON *bloques_json = cJSON_GetObjectItemCaseSensitive(grupo_json, "bloques");
        const cJSON *bloque_json = NULL;
        cJSON_ArrayForEach(bloque_json, bloques_json) {
            if (grupo->cantidad_bloques >= MAX_BLOQUES) {
                break;
            }
            BloqueHorario *bloque = &grupo->bloques[grupo->cantidad_bloques];

            const cJSON *dia = cJSON_GetObjectItemCaseSensitive(bloque_json, "dia");
            const cJSON *hora_inicio = cJSON_GetObjectItemCaseSensitive(bloque_json, "hora_inicio");
            const cJSON *hora_fin = cJSON_GetObjectItemCaseSensitive(bloque_json, "hora_fin");

            /* 'dia' es un solo caracter ('L','K','M','J','V','S'), pero en
             * JSON solo existe el tipo string: se toma el primer char. */
            bloque->dia = (cJSON_IsString(dia) && dia->valuestring[0] != '\0') ? dia->valuestring[0] : '\0';
            bloque->hora_inicio = cJSON_IsNumber(hora_inicio) ? hora_inicio->valueint : 0;
            bloque->hora_fin = cJSON_IsNumber(hora_fin) ? hora_fin->valueint : 0;

            grupo->cantidad_bloques++;
        }

        curso->cantidad_grupos++;
    }

    return EXITO;
}

/* ---------------------------------------------------------------------
 * Funciones publicas (declaradas en carga.h)
 * --------------------------------------------------------------------- */

int cargar_catalogo(const char *ruta, Catalogo *catalogo) {
    if (ruta == NULL || catalogo == NULL) {
        return ERROR_ARCHIVO;
    }
    catalogo->cantidad_cursos = 0;

    char *texto = leer_archivo_completo(ruta);
    if (texto == NULL) {
        return ERROR_ARCHIVO;
    }

    cJSON *raiz = cJSON_Parse(texto);
    free(texto);
    if (raiz == NULL) {
        return ERROR_FORMATO;
    }

    const cJSON *cursos_json = cJSON_GetObjectItemCaseSensitive(raiz, "cursos");
    if (!cJSON_IsArray(cursos_json)) {
        cJSON_Delete(raiz);
        return ERROR_FORMATO;
    }

    const cJSON *curso_json = NULL;
    cJSON_ArrayForEach(curso_json, cursos_json) {
        if (catalogo->cantidad_cursos >= MAX_CURSOS) {
            cJSON_Delete(raiz);
            return ERROR_MEMORIA;
        }

        int resultado = cargar_curso(curso_json, &catalogo->cursos[catalogo->cantidad_cursos]);
        if (resultado != EXITO) {
            cJSON_Delete(raiz);
            return resultado;
        }
        catalogo->cantidad_cursos++;
    }

    cJSON_Delete(raiz);
    return EXITO;
}

int cargar_historial(const char *ruta, Historial *historial) {
    if (ruta == NULL || historial == NULL) {
        return ERROR_ARCHIVO;
    }
    historial->cantidad_aprobados = 0;

    char *texto = leer_archivo_completo(ruta);
    if (texto == NULL) {
        return ERROR_ARCHIVO;
    }

    cJSON *raiz = cJSON_Parse(texto);
    free(texto);
    if (raiz == NULL) {
        return ERROR_FORMATO;
    }

    const cJSON *aprobados_json = cJSON_GetObjectItemCaseSensitive(raiz, "aprobados");
    if (!cJSON_IsArray(aprobados_json)) {
        cJSON_Delete(raiz);
        return ERROR_FORMATO;
    }

    cargar_lista_codigos(aprobados_json, historial->aprobados, MAX_CURSOS, &historial->cantidad_aprobados);

    cJSON_Delete(raiz);
    return EXITO;
}

void liberar_catalogo(Catalogo *catalogo) {
    if (catalogo == NULL) {
        return;
    }
    /* Catalogo solo usa arreglos estaticos (ver estructuras.h), no hay
     * memoria dinamica que liberar. Reiniciar el contador basta para
     * dejarlo en un estado limpio y reutilizable. */
    catalogo->cantidad_cursos = 0;
}

void liberar_historial(Historial *historial) {
    if (historial == NULL) {
        return;
    }
    /* Mismo caso que liberar_catalogo: Historial tambien es un arreglo
     * estatico, no hay nada reservado dinamicamente. */
    historial->cantidad_aprobados = 0;
}
