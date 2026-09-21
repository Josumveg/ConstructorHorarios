/*
 * Pruebas de estudiante_aprobo(), cumple_requisitos(), cumple_correquisitos()
 * y determinar_matriculable().
 *
 * Compilar y correr (desde etapa1-c/):
 *   gcc -Wall -Wextra -std=c11 -Iinclude -Ilib/cjson -g \
 *       tests/requisitos/test_requisitos.c src/requisitos.c \
 *       -o build/test_requisitos && ./build/test_requisitos
 *
 */

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "../../include/requisitos.h"

/* Agrega un curso vacío (sin requisitos ni correquisitos) al catalogo y retorna su índice */
static int agregar_curso(Catalogo *catalogo, const char *codigo) {
    int i = catalogo->cantidad_cursos;

    strcpy(catalogo->cursos[i].codigo, codigo);
    catalogo->cursos[i].cantidad_requisitos = 0;
    catalogo->cursos[i].cantidad_correquisitos = 0;
    catalogo->cursos[i].matriculable = 0;
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

/* Agrega codigo_correq a la lista de correquisitos del curso en indice_curso */
static void agregar_correquisito(Catalogo *catalogo, int indice_curso,
                                  const char *codigo_correq) {
    Curso *curso = &catalogo->cursos[indice_curso];

    strcpy(curso->correquisitos[curso->cantidad_correquisitos], codigo_correq);
    curso->cantidad_correquisitos++;
}

/* Agrega codigo_curso al historial de aprobados */
static void agregar_aprobado(Historial *historial, const char *codigo_curso) {
    strcpy(historial->aprobados[historial->cantidad_aprobados], codigo_curso);
    historial->cantidad_aprobados++;
}

static void test_estudiante_aprobo(void) {
    Historial historial;

    memset(&historial, 0, sizeof(historial));
    agregar_aprobado(&historial, "CE1101");
    agregar_aprobado(&historial, "MA1102");

    assert(estudiante_aprobo(&historial, "CE1101") == 1);
    assert(estudiante_aprobo(&historial, "MA1403") == 0);

    printf("OK: estudiante_aprobo encuentra y no encuentra códigos\n");
}

/* Curso sin requisitos ni correquisitos. */
static void test_curso_sin_requisitos_ni_correquisitos(void) {
    Catalogo catalogo;
    Historial historial;
    int a;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));
    a = agregar_curso(&catalogo, "SE1400");

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[a].matriculable == 1);

    printf("OK: curso sin requisitos ni correquisitos es matriculable\n");
}

/* Curso con todos los requisitos aprobados. */
static void test_todos_los_requisitos_aprobados(void) {
    Catalogo catalogo;
    Historial historial;
    int base, avanzado;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    base = agregar_curso(&catalogo, "CE1101");
    avanzado = agregar_curso(&catalogo, "CE1102");
    agregar_requisito(&catalogo, avanzado, "CE1101");

    agregar_aprobado(&historial, "CE1101");

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[base].matriculable == 0); /* ya aprobado */
    assert(catalogo.cursos[avanzado].matriculable == 1);

    printf("OK: curso con todos los requisitos aprobados es matriculable\n");
}

/* Curso con un requisito no aprobados. */
static void test_requisito_no_aprobado(void) {
    Catalogo catalogo;
    Historial historial;
    int base, avanzado;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    base = agregar_curso(&catalogo, "CE1101");
    avanzado = agregar_curso(&catalogo, "CE1102");
    agregar_requisito(&catalogo, avanzado, "CE1101");
    /* CE1101 no esta en el historial */

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[base].matriculable == 1);
    assert(catalogo.cursos[avanzado].matriculable == 0);

    printf("OK: curso con un requisito no aprobado no es matriculable\n");
}

/* Requisito que no existe en el cátalogo ni esta aprobado. */
static void test_requisito_fuera_del_catalogo(void) {
    Catalogo catalogo;
    Historial historial;
    int ci1230;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    ci1230 = agregar_curso(&catalogo, "CI1230");
    agregar_requisito(&catalogo, ci1230, "CI0200");
    agregar_requisito(&catalogo, ci1230, "CI0202");

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[ci1230].matriculable == 0);

    printf("OK: requisito fuera del cátalogo y no aprobado no es matriculable\n");
}

/* Curso ya aprobado. */
static void test_curso_ya_aprobado(void) {
    Catalogo catalogo;
    Historial historial;
    int curso;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    curso = agregar_curso(&catalogo, "CE1101");
    agregar_aprobado(&historial, "CE1101");

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[curso].matriculable == 0);

    printf("OK: curso ya aprobado no se vuelve a marcar matriculable\n");
}

/* Correquisitos mutuos. */
static void test_correquisitos_mutuos(void) {
    Catalogo catalogo;
    Historial historial;
    int qu1104, qu1107;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    qu1104 = agregar_curso(&catalogo, "QU1104");
    qu1107 = agregar_curso(&catalogo, "QU1107");
    agregar_correquisito(&catalogo, qu1104, "QU1107");
    agregar_correquisito(&catalogo, qu1107, "QU1104");

    determinar_matriculable(&catalogo, &historial);

    assert(catalogo.cursos[qu1104].matriculable == 1);
    assert(catalogo.cursos[qu1107].matriculable == 1);

    printf("OK: correquisitos mutuos quedan matriculables sin recursion\n");
}

/* Atrapa errores de NULL. */
static void test_guardas_null(void) {
    Catalogo catalogo;
    Historial historial;

    memset(&catalogo, 0, sizeof(catalogo));
    memset(&historial, 0, sizeof(historial));

    assert(estudiante_aprobo(NULL, "CE1101") == 0);
    assert(estudiante_aprobo(&historial, NULL) == 0);

    assert(cumple_requisitos(NULL, &historial) == 0);
    assert(cumple_requisitos(&catalogo.cursos[0], NULL) == 0);

    assert(cumple_correquisitos(NULL, &historial, &catalogo) == 0);
    assert(cumple_correquisitos(&catalogo.cursos[0], NULL, &catalogo) == 0);
    assert(cumple_correquisitos(&catalogo.cursos[0], &historial, NULL) == 0);

    determinar_matriculable(NULL, &historial);
    determinar_matriculable(&catalogo, NULL);

    printf("OK: guardas de NULL no revientan\n");
}

int main(void) {
    test_estudiante_aprobo();
    test_curso_sin_requisitos_ni_correquisitos();
    test_todos_los_requisitos_aprobados();
    test_requisito_no_aprobado();
    test_requisito_fuera_del_catalogo();
    test_curso_ya_aprobado();
    test_correquisitos_mutuos();
    test_guardas_null();

    printf("\nTodas las pruebas de requisitos/correquisitos pasaron.\n");
    return 0;
}
