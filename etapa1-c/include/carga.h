#ifndef CARGA_H
#define CARGA_H

#include "estructuras.h"

/*
 * Modulo: Estructuras, constantes y carga de archivos
 * Responsable: Jose
 * Rubro: Carga de datos (10) + Memoria/estructuras (15)
 */

/* Carga el catalogo de cursos desde el archivo JSON en 'ruta' hacia 'catalogo'.
 * Retorna EXITO o un codigo de error definido en constantes.h. */
int cargar_catalogo(const char *ruta, Catalogo *catalogo);

/* Carga el historial de cursos aprobados del estudiante desde el archivo
 * JSON en 'ruta'. */
int cargar_historial(const char *ruta, Historial *historial);

/* Libera / reinicia cualquier recurso asociado al catalogo. */
void liberar_catalogo(Catalogo *catalogo);

/* Libera / reinicia cualquier recurso asociado al historial. */
void liberar_historial(Historial *historial);

#endif /* CARGA_H */
