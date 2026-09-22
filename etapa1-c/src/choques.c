#include <stddef.h>
#include "../include/choques.h"

/*
 * Modulo: Choques de horario
 * Responsable: Pablo
 *
 * Determina, para cada curso del catálogo, si su horario se cruza con el de algún otro curso. 
 * Trabaja en tres niveles que se apoyan uno en otro donde:
 * primero compara dos bloques horarios sueltos, 
 * luego dos grupos completos, 
 * y al final recorre el catálogo entero comparando cada curso con los demas.
 *
 * Salidas:
 *   - El campo choca_con_otro (0/1) de cada curso del catálogo, escrito por calcular_choques(). 
 *
 * Dos bloques se solapan si son el mismo dia y sus rangos se cruzan en intervalo semiabierto [inicio, fin).
 * Por ejemplo: un curso que termina a las 9:20 y otro que empieza a las 9:20 NO chocan.
 * Las horas son enteros en formato HHMM (730 = 7:30), asi que se comparan directamente con < y > sin convertir nada.
 * Solo se comparan cursos DISTINTOS. Que los grupos de un mismo curso se solapen es normal, 
 * el estudiante matricula uno solo.
 * Un curso se marca si algún grupo suyo choca con algún grupo de otro curso. 
 * Con el dataset real eso deja los 45 cursos marcados, porque a nivel de curso el choque es casi inevitable.
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

    /* Inicializar todos los cursos como sin choque */
    for (int i = 0; i < catalogo->cantidad_cursos; i++) {
        catalogo->cursos[i].choca_con_otro = 0;
    }

    /* Comparar cada curso con los cursos siguientes */
    for (int i = 0; i < catalogo->cantidad_cursos; i++) {

        for (int j = i + 1; j < catalogo->cantidad_cursos; j++) {

            Curso *curso1 = &catalogo->cursos[i];
            Curso *curso2 = &catalogo->cursos[j];

            for (int g1 = 0; g1 < curso1->cantidad_grupos; g1++) {

                for (int g2 = 0; g2 < curso2->cantidad_grupos; g2++) {

                    if (grupos_chocan(&curso1->grupos[g1],
                                      &curso2->grupos[g2])) {

                        curso1->choca_con_otro = 1;
                        curso2->choca_con_otro = 1;
                    }
                }
            }
        }
    }
}
