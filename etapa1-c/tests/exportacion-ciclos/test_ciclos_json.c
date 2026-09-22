#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "exportacion.h"
#include "carga.h"
#include "cJSON.h"

static Catalogo catalogo;
static int reservas, fallar_en, pendientes;

static void *reservar(size_t cantidad) {
    void *p;
    if (reservas++ == fallar_en) return NULL;
    p = malloc(cantidad);
    if (p) pendientes++;
    return p;
}

static void liberar(void *p) {
    if (p) { pendientes--; free(p); }
}

static cJSON *leer_json(const char *ruta) {
    FILE *f = fopen(ruta, "rb");
    long tamano;
    char *texto;
    cJSON *raiz;
    assert(f);
    assert(fseek(f, 0, SEEK_END) == 0);
    tamano = ftell(f);
    assert(tamano >= 0);
    rewind(f);
    texto = malloc((size_t)tamano + 1);
    assert(texto);
    assert(fread(texto, 1, (size_t)tamano, f) == (size_t)tamano);
    texto[tamano] = '\0';
    assert(fclose(f) == 0);
    raiz = cJSON_Parse(texto);
    free(texto);
    assert(raiz);
    return raiz;
}

static void preparar(void) {
    memset(&catalogo, 0, sizeof(catalogo));
    catalogo.cantidad_cursos = 5;
    strcpy(catalogo.cursos[0].codigo, "A");
    strcpy(catalogo.cursos[1].codigo, "B");
    strcpy(catalogo.cursos[2].codigo, "C");
    strcpy(catalogo.cursos[3].codigo, "D");
    strcpy(catalogo.cursos[4].codigo, "E");
}

static void requisito(int desde, const char *hacia) {
    Curso *c = &catalogo.cursos[desde];
    strcpy(c->requisitos[c->cantidad_requisitos++], hacia);
}

static void verificar_reporte(const char *esperado) {
    cJSON *raiz, *ciclos, *comparacion, *cursos;
    /* No se llama a detectar_ciclos antes: exportar funciona por si sola. */
    assert(exportar_catalogo(&catalogo, "build/prueba_ciclos.json") == EXITO);
    raiz = leer_json("build/prueba_ciclos.json");
    comparacion = cJSON_Parse(esperado);
    assert(comparacion);
    ciclos = cJSON_GetObjectItemCaseSensitive(raiz, "ciclos");
    assert(cJSON_Compare(ciclos, comparacion, 1));
    assert(cJSON_IsBool(cJSON_GetObjectItemCaseSensitive(raiz, "hay_ciclos")));
    assert(cJSON_IsTrue(cJSON_GetObjectItemCaseSensitive(raiz, "hay_ciclos")) ==
           (cJSON_GetArraySize(comparacion) > 0));
    cursos = cJSON_GetObjectItemCaseSensitive(raiz, "cursos");
    assert(cJSON_GetArraySize(cursos) == catalogo.cantidad_cursos);
    cJSON_Delete(comparacion);
    cJSON_Delete(raiz);
}

static void probar_memoria(void) {
    cJSON_Hooks hooks = {reservar, liberar};
    int total, resultado;
    preparar();
    requisito(0, "B"); requisito(1, "A");
    cJSON_InitHooks(&hooks);
    fallar_en = -1;
    reservas = 0;
    assert(exportar_catalogo(&catalogo, "build/prueba_ciclos.json") == EXITO);
    total = reservas;
    assert(pendientes == 0);
    for (fallar_en = 0; fallar_en < total; fallar_en++) {
        reservas = 0;
        resultado = exportar_catalogo(&catalogo, "build/prueba_ciclos.json");
        assert(resultado == ERROR_MEMORIA || resultado == EXITO);
        assert(pendientes == 0);
    }
    cJSON_InitHooks(NULL);
    puts("OK: fallos de memoria sin fugas, incluido el reporte de ciclos.");
}

static void probar_catalogo_real(void) {
    cJSON *entrada, *salida, *originales, *exportados;
    cJSON *original, *campo;
    int i = 0;
    assert(cargar_catalogo("data/catalogo.json", &catalogo) == EXITO);
    assert(catalogo.cantidad_cursos > 0);
    verificar_reporte("[]");
    entrada = leer_json("data/catalogo.json");
    salida = leer_json("build/prueba_ciclos.json");
    originales = cJSON_GetObjectItemCaseSensitive(entrada, "cursos");
    exportados = cJSON_GetObjectItemCaseSensitive(salida, "cursos");
    assert(cJSON_GetArraySize(originales) == cJSON_GetArraySize(exportados));
    cJSON_ArrayForEach(original, originales) {
        cJSON *exportado = cJSON_GetArrayItem(exportados, i++);
        cJSON_ArrayForEach(campo, original) {
            assert(cJSON_Compare(campo,
                   cJSON_GetObjectItemCaseSensitive(exportado, campo->string), 1));
        }
    }
    printf("OK: %d cursos reales con todos sus campos conservados.\n", i);
    cJSON_Delete(entrada);
    cJSON_Delete(salida);
    liberar_catalogo(&catalogo);
}

int main(void) {
    preparar();
    requisito(0, "B"); requisito(0, "C");
    requisito(1, "D"); requisito(2, "D");
    verificar_reporte("[]");
    puts("OK: diamante sin falso ciclo.");

    preparar();
    requisito(0, "B"); requisito(1, "C"); requisito(2, "A");
    requisito(3, "E"); requisito(4, "D");
    verificar_reporte("[[\"A\",\"B\",\"C\",\"A\"],[\"D\",\"E\",\"D\"]]");
    puts("OK: ciclos de todos los componentes guardados en JSON.");

    preparar();
    requisito(0, "A");
    verificar_reporte("[[\"A\",\"A\"]]");
    preparar();
    verificar_reporte("[]");
    puts("OK: autorrequisito y exportaciones consecutivas sin datos viejos.");

    memset(&catalogo, 0, sizeof(catalogo));
    verificar_reporte("[]");
    probar_memoria();
    probar_catalogo_real();
    puts("Todas las pruebas de ciclos en JSON pasaron.");
    return 0;
}
