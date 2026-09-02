#ifndef CONSTANTES_H
#define CONSTANTES_H

/*
 * Constantes globales del proyecto CEmestre - Etapa 1.
 *
 * Estos valores son un punto de partida: si el dataset real (4 semestres
 * de las 2 carreras elegidas) necesita mas espacio, ajustenlos aqui y
 * recompilen. Mantener las constantes separadas de estructuras.h permite
 * cambiarlas sin tocar las definiciones de los structs.
 */

/* ---- Longitudes de texto ---- */
#define MAX_LONG_CODIGO   16   /* ej. "CE1101" + margen */
#define MAX_LONG_NOMBRE   80   /* nombre completo del curso */

/* ---- Tamanos de colecciones dentro de un Curso ---- */
#define MAX_BLOQUES       5    /* bloques de horario por grupo (teoria, lab, etc.) */
#define MAX_GRUPOS        10   /* grupos distintos que puede tener un curso */
#define MAX_REQ           10   /* requisitos o correquisitos que puede tener un curso */

/* ---- Tamano del catalogo e historial ---- */
#define MAX_CURSOS        150  /* cursos totales en el catalogo (2 carreras x 4 semestres) */

/* ---- Lectura de archivos ---- */
/* Los 3 archivos (catalogo, historial, salida) son JSON: se leen completos
 * a memoria (no linea por linea) y se parsean/serializan desde ahi. */
#define MAX_LINEA         512     /* buffer generico para strings intermedios (ej. mensajes de error) */
#define MAX_TAMANO_JSON   65536   /* tamano maximo (bytes) de un archivo JSON de entrada a cargar en memoria */

/* ---- Codigos de retorno para funciones de carga/exportacion ---- */
#define EXITO             0
#define ERROR_ARCHIVO     1   /* no se pudo abrir/leer el archivo */
#define ERROR_FORMATO     2   /* el archivo se abrio pero el contenido es invalido */
#define ERROR_MEMORIA     3   /* se supero algun MAX_* definido arriba */

/* ---- Rutas por defecto (pueden sobreescribirse via argumentos de main) ---- */
/* Formato acordado por el equipo: JSON para los 3 archivos. */
#define RUTA_CATALOGO_DEFECTO    "data/catalogo.json"
#define RUTA_HISTORIAL_DEFECTO   "data/historial.json"
#define RUTA_SALIDA_DEFECTO      "data/catalogo_salida.json"

#endif /* CONSTANTES_H */
