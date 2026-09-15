/*
 * Pruebas de construir_grafo_requisitos().
 *
 * Compilar y correr (desde etapa1-c/):
 *   gcc -Wall -Wextra -std=c11 -Iinclude -Ilib/cjson -g \
 *       tests/grafo-requisitos/test_grafo.c src/requisitos.c -o build/test_grafo && \
 *       ./build/test_grafo
 *
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "../../include/requisitos.h"

/* Agrega un curso vacio (sin requisitos) al catalogo y retorna su indice */
static int agregar_curso(Catalogo *catalogo, const char *codigo) {
    int i = catalogo->cantidad_cursos;

    strcpy(catalogo->cursos[i].codigo, codigo);
    catalogo->cursos[i].cantidad_requisitos = 0;
    catalogo->cantidad_cursos++;

    return i;
}

/* Agrega codigo_requisito a la lista de requisitos del curso en indice_curso */
static void agregar_requisito(Catalogo *catalogo, int indice_curso,
                               const char *codigo_requisito) {
    Curso *curso = &catalogo->cursos[indice_curso];

    strcpy(curso->requisitos[curso->cantidad_requisitos], codigo_requisito);
    curso->cantidad_requisitos++;
}

/* Caso 1: cadena de requisitos A <- B <- C (C requiere B, B requiere A), mas un curso D sin requisitos. */
static void test_cadena_y_curso_sin_requisitos(void) {
    Catalogo catalogo;
    GrafoRequisitos grafo;
    int a, b, c, d;

    memset(&catalogo, 0, sizeof(catalogo));
    a = agregar_curso(&catalogo, "A");
    b = agregar_curso(&catalogo, "B");
    c = agregar_curso(&catalogo, "C");
    d = agregar_curso(&catalogo, "D");

    agregar_requisito(&catalogo, b, "A"); /* B requiere A */
    agregar_requisito(&catalogo, c, "B"); /* C requiere B */
    /* D no tiene requisitos */

    construir_grafo_requisitos(&catalogo, &grafo);

    assert(grafo.cantidad_nodos == 4);

    assert(grafo.cantidad_adyacentes[a] == 0);

    assert(grafo.cantidad_adyacentes[b] == 1);
    assert(grafo.adyacentes[b][0] == a);

    assert(grafo.cantidad_adyacentes[c] == 1);
    assert(grafo.adyacentes[c][0] == b);

    assert(grafo.cantidad_adyacentes[d] == 0);

    printf("OK: cadena de requisitos y curso sin requisitos\n");
}

/* Caso 2: requisito con codigo inexistente (como CI1230 -> CI0200/CI0202) se omite sin romper los indices de los demas requisitos del curso. */
static void test_requisito_inexistente_se_omite(void) {
    Catalogo catalogo;
    GrafoRequisitos grafo;
    int ci1107, ci1230;

    memset(&catalogo, 0, sizeof(catalogo));
    ci1107 = agregar_curso(&catalogo, "CI1107");
    ci1230 = agregar_curso(&catalogo, "CI1230");

    /* CI1230 (Ingles I) requiere CI0200 y CI0202, que no existen en el catalogo, y ademas CI1107, que si existe */
    agregar_requisito(&catalogo, ci1230, "CI0200");
    agregar_requisito(&catalogo, ci1230, "CI1107");
    agregar_requisito(&catalogo, ci1230, "CI0202");

    construir_grafo_requisitos(&catalogo, &grafo);

    /* de los 3 requisitos declarados, solo CI1107 se resuelve */
    assert(grafo.cantidad_adyacentes[ci1230] == 1);
    assert(grafo.adyacentes[ci1230][0] == ci1107);

    /* el indice de CI1107 no se ve afectado */
    assert(grafo.cantidad_adyacentes[ci1107] == 0);

    printf("OK: requisito con codigo inexistente se omite sin romper indices\n");
}

/* Caso 3: ciclo A -> B -> A queda representado tal cual en el grafo, porque filtrarlo es trabajo del DFS de exportacion.c, no de este modulo. */
static void test_ciclo_no_se_filtra(void) {
    Catalogo catalogo;
    GrafoRequisitos grafo;
    int a, b;

    memset(&catalogo, 0, sizeof(catalogo));
    a = agregar_curso(&catalogo, "A");
    b = agregar_curso(&catalogo, "B");

    agregar_requisito(&catalogo, a, "B"); /* A requiere B */
    agregar_requisito(&catalogo, b, "A"); /* B requiere A: ciclo */

    construir_grafo_requisitos(&catalogo, &grafo);

    assert(grafo.cantidad_adyacentes[a] == 1);
    assert(grafo.adyacentes[a][0] == b);

    assert(grafo.cantidad_adyacentes[b] == 1);
    assert(grafo.adyacentes[b][0] == a);

    printf("OK: ciclo A->B->A queda representado en el grafo\n");
}

/* Guardas de NULL: no debe fallar (segfault) con catalogo o grafo nulos */
static void test_guardas_null(void) {
    Catalogo catalogo;
    GrafoRequisitos grafo;

    memset(&catalogo, 0, sizeof(catalogo));

    construir_grafo_requisitos(NULL, &grafo);
    construir_grafo_requisitos(&catalogo, NULL);

    printf("OK: guardas de NULL no revientan\n");
}

int main(void) {
    test_cadena_y_curso_sin_requisitos();
    test_requisito_inexistente_se_omite();
    test_ciclo_no_se_filtra();
    test_guardas_null();

    printf("\nTodas las pruebas de construir_grafo_requisitos() pasaron.\n");
    return 0;
}
