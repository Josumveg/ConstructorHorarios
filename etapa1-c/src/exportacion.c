#include <stdio.h>
#include <string.h>
#include "cJSON.h"
#include "../include/exportacion.h"

/* Modulo de Sebastian. Conserva el contrato JSON de data/README.md. */
static int cantidad_valida(int cantidad, int maximo) {
    return cantidad >= 0 && cantidad <= maximo;
}

/* Se validan limites y terminadores antes de leer los arreglos del struct. */
static int catalogo_valido(const Catalogo *catalogo) {
    int i, j;
    if (!cantidad_valida(catalogo->cantidad_cursos, MAX_CURSOS)) return 0;
    for (i = 0; i < catalogo->cantidad_cursos; i++) {
        const Curso *c = &catalogo->cursos[i];
        if (!memchr(c->codigo, '\0', sizeof(c->codigo)) ||
            !memchr(c->nombre, '\0', sizeof(c->nombre)) ||
            !cantidad_valida(c->cantidad_carreras, MAX_CARRERAS) ||
            !cantidad_valida(c->cantidad_grupos, MAX_GRUPOS) ||
            !cantidad_valida(c->cantidad_requisitos, MAX_REQ) ||
            !cantidad_valida(c->cantidad_correquisitos, MAX_REQ)) return 0;
        for (j = 0; j < c->cantidad_carreras; j++)
            if (!memchr(c->carreras[j], '\0', sizeof(c->carreras[j]))) return 0;
        for (j = 0; j < c->cantidad_requisitos; j++)
            if (!memchr(c->requisitos[j], '\0', sizeof(c->requisitos[j]))) return 0;
        for (j = 0; j < c->cantidad_correquisitos; j++)
            if (!memchr(c->correquisitos[j], '\0', sizeof(c->correquisitos[j]))) return 0;
        for (j = 0; j < c->cantidad_grupos; j++)
            if (!cantidad_valida(c->grupos[j].cantidad_bloques, MAX_BLOQUES)) return 0;
    }
    return 1;
}

/* cJSON toma posesion del hijo solamente si la insercion tiene exito. */
static int agregar_elemento(cJSON *arreglo, cJSON *hijo) {
    if (!hijo) return 0;
    if (!cJSON_AddItemToArray(arreglo, hijo)) {
        cJSON_Delete(hijo);
        return 0;
    }
    return 1;
}

static int serializar_curso(cJSON *objeto, const Curso *curso) {
    cJSON *carreras, *requisitos, *correquisitos, *grupos;
    int i, j;
    if (!cJSON_AddStringToObject(objeto, "codigo", curso->codigo) ||
        !cJSON_AddStringToObject(objeto, "nombre", curso->nombre) ||
        !cJSON_AddNumberToObject(objeto, "creditos", curso->creditos) ||
        !cJSON_AddBoolToObject(objeto, "choca_con_otro", curso->choca_con_otro != 0) ||
        !cJSON_AddBoolToObject(objeto, "matriculable", curso->matriculable != 0)) return 0;
    carreras = cJSON_AddArrayToObject(objeto, "carreras");
    requisitos = cJSON_AddArrayToObject(objeto, "requisitos");
    correquisitos = cJSON_AddArrayToObject(objeto, "correquisitos");
    grupos = cJSON_AddArrayToObject(objeto, "grupos");
    if (!carreras || !requisitos || !correquisitos || !grupos) return 0;
    for (i = 0; i < curso->cantidad_carreras; i++)
        if (!agregar_elemento(carreras, cJSON_CreateString(curso->carreras[i]))) return 0;
    for (i = 0; i < curso->cantidad_requisitos; i++)
        if (!agregar_elemento(requisitos, cJSON_CreateString(curso->requisitos[i]))) return 0;
    for (i = 0; i < curso->cantidad_correquisitos; i++)
        if (!agregar_elemento(correquisitos, cJSON_CreateString(curso->correquisitos[i]))) return 0;
    for (i = 0; i < curso->cantidad_grupos; i++) {
        const Grupo *grupo = &curso->grupos[i];
        cJSON *obj_grupo = cJSON_CreateObject();
        cJSON *bloques;
        if (!agregar_elemento(grupos, obj_grupo)) return 0;
        if (!cJSON_AddNumberToObject(obj_grupo, "numero_grupo", grupo->numero_grupo)) return 0;
        bloques = cJSON_AddArrayToObject(obj_grupo, "bloques");
        if (!bloques) return 0;
        for (j = 0; j < grupo->cantidad_bloques; j++) {
            const BloqueHorario *bloque = &grupo->bloques[j];
            char dia[2] = {bloque->dia, '\0'};
            cJSON *obj_bloque = cJSON_CreateObject();
            if (!agregar_elemento(bloques, obj_bloque)) return 0;
            if (!cJSON_AddStringToObject(obj_bloque, "dia", dia) ||
                !cJSON_AddNumberToObject(obj_bloque, "hora_inicio", bloque->hora_inicio) ||
                !cJSON_AddNumberToObject(obj_bloque, "hora_fin", bloque->hora_fin)) return 0;
        }
    }
    return 1;
}

int exportar_catalogo(const Catalogo *catalogo, const char *ruta_salida) {
    cJSON *raiz, *cursos;
    char *texto;
    FILE *archivo;
    int i, resultado = EXITO;
    size_t longitud;
    if (!catalogo || !ruta_salida) return ERROR_ARCHIVO;
    if (!catalogo_valido(catalogo)) return ERROR_FORMATO;
    raiz = cJSON_CreateObject();
    if (!raiz) return ERROR_MEMORIA;
    cursos = cJSON_AddArrayToObject(raiz, "cursos");
    if (!cursos) { cJSON_Delete(raiz); return ERROR_MEMORIA; }
    for (i = 0; i < catalogo->cantidad_cursos; i++) {
        cJSON *curso = cJSON_CreateObject();
        if (!agregar_elemento(cursos, curso) || !serializar_curso(curso, &catalogo->cursos[i])) {
            cJSON_Delete(raiz);
            return ERROR_MEMORIA;
        }
    }
    texto = cJSON_Print(raiz);
    cJSON_Delete(raiz);
    if (!texto) return ERROR_MEMORIA;
    /* Solo se abre el destino despues de construir el JSON completo. */
    archivo = fopen(ruta_salida, "wb");
    if (!archivo) { cJSON_free(texto); return ERROR_ARCHIVO; }
    longitud = strlen(texto);
    if (fwrite(texto, 1, longitud, archivo) != longitud || fputc('\n', archivo) == EOF)
        resultado = ERROR_ARCHIVO;
    if (fclose(archivo) != 0) resultado = ERROR_ARCHIVO;
    cJSON_free(texto);
    return resultado;
}

/* Blanco: no visitado; gris: en_pila; negro: visitado y fuera de la pila.
 * Solo una arista hacia gris cierra un ciclo. El camino permite reportarlo.
 * El mismo recorrido sirve a ambas funciones publicas, sin estado global. */
static int recorrer_dfs(const GrafoRequisitos *grafo, int nodo,
                        int *visitados, int *en_pila, int *camino,
                        int profundidad, const Catalogo *catalogo) {
    int i, hay_ciclo = 0;
    visitados[nodo] = 1;
    en_pila[nodo] = 1;
    camino[profundidad] = nodo;
    for (i = 0; i < grafo->cantidad_adyacentes[nodo]; i++) {
        int vecino = grafo->adyacentes[nodo][i];
        if (en_pila[vecino]) {
            hay_ciclo = 1;
            if (catalogo) {
                int inicio = 0, j;
                while (inicio <= profundidad && camino[inicio] != vecino) inicio++;
                printf("Ciclo de requisitos: ");
                for (j = inicio; j <= profundidad; j++)
                    printf("%s -> ", catalogo->cursos[camino[j]].codigo);
                printf("%s\n", catalogo->cursos[vecino].codigo);
            }
        } else if (!visitados[vecino]) {
            if (recorrer_dfs(grafo, vecino, visitados, en_pila, camino,
                             profundidad + 1, catalogo)) hay_ciclo = 1;
        }
    }
    en_pila[nodo] = 0;
    return hay_ciclo;
}

static int grafo_valido(const GrafoRequisitos *grafo) {
    int i, j;
    if (!grafo || !cantidad_valida(grafo->cantidad_nodos, MAX_CURSOS)) return 0;
    for (i = 0; i < grafo->cantidad_nodos; i++) {
        if (!cantidad_valida(grafo->cantidad_adyacentes[i], MAX_REQ)) return 0;
        for (j = 0; j < grafo->cantidad_adyacentes[i]; j++)
            if (grafo->adyacentes[i][j] < 0 ||
                grafo->adyacentes[i][j] >= grafo->cantidad_nodos) return 0;
    }
    return 1;
}

int dfs_detectar_ciclo(const GrafoRequisitos *grafo, int nodo,
                        int *visitados, int *en_pila) {
    int camino[MAX_CURSOS];
    if (!visitados || !en_pila || !grafo_valido(grafo) ||
        nodo < 0 || nodo >= grafo->cantidad_nodos) return 0;
    if (en_pila[nodo]) return 1;
    if (visitados[nodo]) return 0;
    return recorrer_dfs(grafo, nodo, visitados, en_pila, camino, 0, NULL);
}

int detectar_ciclos(Catalogo *catalogo) {
    GrafoRequisitos grafo = {0};
    int visitados[MAX_CURSOS] = {0}, en_pila[MAX_CURSOS] = {0};
    int camino[MAX_CURSOS], i, hay_ciclo = 0;
    if (!catalogo || !catalogo_valido(catalogo)) return 0;
    construir_grafo_requisitos(catalogo, &grafo);
    if (!grafo_valido(&grafo)) return 0;
    for (i = 0; i < grafo.cantidad_nodos; i++)
        if (!visitados[i] && recorrer_dfs(&grafo, i, visitados, en_pila,
                                         camino, 0, catalogo)) hay_ciclo = 1;
    return hay_ciclo;
}
