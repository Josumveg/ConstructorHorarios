#include <stddef.h>
#include "../include/choques.h"

/*
 * Modulo: Choques de horario
 * Responsable: Pablo
 *
 * TODO (Pablo):
 *   - Implementar bloques_se_solapan comparando dia y el rango [hora_inicio, hora_fin).
 *   - Implementar grupos_chocan reutilizando bloques_se_solapan para cada
 *     par de bloques entre los dos grupos.
 *   - Implementar calcular_choques recorriendo el catalogo y marcando
 *     curso->choca_con_otro cuando corresponda (definir con el equipo que
 *     significa "chocar": entre grupos del mismo curso, o entre cursos
 *     distintos que el estudiante quisiera matricular a la vez).
 */

int bloques_se_solapan(const BloqueHorario *a, const BloqueHorario *b) {
    if (a == NULL || b == NULL) {
        return 0;
    }

    if (a->dia != b->dia) {
        return 0;
    }

    if (a->hora_inicio < b->hora_fin &&
        b->hora_inicio < a->hora_fin) {
        return 1;
    }

    return 0;
}

int grupos_chocan(const Grupo *g1, const Grupo *g2) {
    if (g1 == NULL || g2 == NULL) {
        return 0;
    }

    for (int i = 0; i < g1->cantidad_bloques; i++) {
        for (int j = 0; j < g2->cantidad_bloques; j++) {

            if (bloques_se_solapan(&g1->bloques[i],
                                   &g2->bloques[j])) {
                return 1;
            }
        }
    }

    return 0;
}
void calcular_choques(Catalogo *catalogo) {
    if (catalogo == NULL) {
        return;
    }

    /* TODO: recorrer catalogo->cursos y actualizar choca_con_otro */
}
