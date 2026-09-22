#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "exportacion.h"

/* Estático para no colocar todo el catálogo en la pila. */
static Catalogo catalogo;

static void preparar_catalogo(void) {
    memset(&catalogo, 0, sizeof(catalogo));
    catalogo.cantidad_cursos = 4;

    strcpy(catalogo.cursos[0].codigo, "A");
    strcpy(catalogo.cursos[1].codigo, "B");
    strcpy(catalogo.cursos[2].codigo, "C");
    strcpy(catalogo.cursos[3].codigo, "D");
}

static void agregar_requisito(int curso, const char *codigo) {
    Curso *c = &catalogo.cursos[curso];

    assert(c->cantidad_requisitos < MAX_REQ);
    strcpy(c->requisitos[c->cantidad_requisitos], codigo);
    c->cantidad_requisitos++;
}

static void probar_sin_ciclos(void) {
    preparar_catalogo();

    /* A requiere B; B requiere C. */
    agregar_requisito(0, "B");
    agregar_requisito(1, "C");

    assert(detectar_ciclos(&catalogo) == 0);
    puts("OK: cadena sin ciclos.");
}

static void probar_requisito_compartido(void) {
    preparar_catalogo();

    /* A requiere B y C; ambos requieren D. No hay ciclo. */
    agregar_requisito(0, "B");
    agregar_requisito(0, "C");
    agregar_requisito(1, "D");
    agregar_requisito(2, "D");

    assert(detectar_ciclos(&catalogo) == 0);
    puts("OK: requisito compartido no produce un falso ciclo.");
}

static void probar_ciclo_tres_cursos(void) {
    preparar_catalogo();

    agregar_requisito(0, "B");
    agregar_requisito(1, "C");
    agregar_requisito(2, "A");

    assert(detectar_ciclos(&catalogo) == 1);
    puts("OK: ciclo A -> B -> C -> A.");
}

static void probar_autorrequisito(void) {
    preparar_catalogo();
    agregar_requisito(0, "A");

    assert(detectar_ciclos(&catalogo) == 1);
    puts("OK: autorrequisito A -> A.");
}

static void probar_ciclo_separado(void) {
    preparar_catalogo();

    /* A y B no tienen requisitos; el ciclo está entre C y D. */
    agregar_requisito(2, "D");
    agregar_requisito(3, "C");

    assert(detectar_ciclos(&catalogo) == 1);
    puts("OK: ciclo encontrado en otro componente.");
}

static void probar_dfs_directamente(void) {
    GrafoRequisitos grafo = {0};
    int visitados[MAX_CURSOS] = {0};
    int en_pila[MAX_CURSOS] = {0};
    int i;

    preparar_catalogo();
    agregar_requisito(0, "B");
    agregar_requisito(1, "A");

    construir_grafo_requisitos(&catalogo, &grafo);

    assert(dfs_detectar_ciclo(&grafo, 0, visitados, en_pila) == 1);

    /* Al terminar, no debe quedar ningún nodo en la pila activa. */
    for (i = 0; i < grafo.cantidad_nodos; i++) {
        assert(en_pila[i] == 0);
    }

    puts("OK: DFS directo y limpieza de la pila.");
}

static void probar_catalogo_vacio(void) {
    memset(&catalogo, 0, sizeof(catalogo));

    assert(detectar_ciclos(&catalogo) == 0);
    assert(detectar_ciclos(NULL) == 0);
    puts("OK: catalogo vacio y argumento nulo.");
}

int main(void) {
    probar_sin_ciclos();
    probar_requisito_compartido();
    probar_ciclo_tres_cursos();
    probar_autorrequisito();
    probar_ciclo_separado();
    probar_dfs_directamente();
    probar_catalogo_vacio();

    puts("\nTodas las pruebas de ciclos pasaron.");
    return 0;
}