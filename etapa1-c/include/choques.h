#ifndef CHOQUES_H
#define CHOQUES_H

#include "estructuras.h"

/*
 * Modulo: Choques de horario
 * Responsable: Pablo
 * Rubro: Choques de horario (16)
 */

/* Retorna 1 si los bloques 'a' y 'b' se solapan en dia/hora, 0 si no. */
int bloques_se_solapan(const BloqueHorario *a, const BloqueHorario *b);

/* Retorna 1 si algun bloque de 'g1' choca con algun bloque de 'g2'. */
int grupos_chocan(const Grupo *g1, const Grupo *g2);

/* Recorre el catalogo y marca choca_con_otro en cada Curso segun corresponda. */
void calcular_choques(Catalogo *catalogo);

#endif /* CHOQUES_H */
