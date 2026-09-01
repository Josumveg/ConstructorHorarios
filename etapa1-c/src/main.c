#include <stdio.h>
#include "../include/estructuras.h"
#include "../include/constantes.h"
#include "../include/carga.h"
#include "../include/choques.h"
#include "../include/requisitos.h"
#include "../include/exportacion.h"

/*
 * Punto de entrada del programa. Integracion de los 4 modulos:
 * cargar -> calcular choques -> calcular matriculabilidad -> detectar
 * ciclos -> exportar.
 *
 * Tarea compartida por todo el equipo (ver seccion 5 de
 * distribucion-tareas-etapa1-cemestre.md): mejor completarla en conjunto
 * una vez que cada modulo este probado por separado.
 *
 * Uso esperado:
 *   cemestre [ruta_catalogo] [ruta_historial] [ruta_salida]
 * Si no se pasan argumentos, se usan las rutas por defecto de constantes.h.
 */
int main(int argc, char *argv[]) {
    const char *ruta_catalogo = (argc > 1) ? argv[1] : RUTA_CATALOGO_DEFECTO;
    const char *ruta_historial = (argc > 2) ? argv[2] : RUTA_HISTORIAL_DEFECTO;
    const char *ruta_salida = (argc > 3) ? argv[3] : RUTA_SALIDA_DEFECTO;

    Catalogo catalogo;
    Historial historial;

    if (cargar_catalogo(ruta_catalogo, &catalogo) != EXITO) {
        fprintf(stderr, "Error cargando catalogo: %s\n", ruta_catalogo);
        return 1;
    }

    if (cargar_historial(ruta_historial, &historial) != EXITO) {
        fprintf(stderr, "Error cargando historial: %s\n", ruta_historial);
        liberar_catalogo(&catalogo);
        return 1;
    }

    /* TODO (equipo): una vez que cada modulo este listo, conectar aqui: */
    calcular_choques(&catalogo);
    determinar_matriculable(&catalogo, &historial);
    detectar_ciclos(&catalogo);

    if (exportar_catalogo(&catalogo, ruta_salida) != EXITO) {
        fprintf(stderr, "Error exportando catalogo a: %s\n", ruta_salida);
        liberar_catalogo(&catalogo);
        liberar_historial(&historial);
        return 1;
    }

    printf("Catalogo exportado exitosamente a: %s\n", ruta_salida);

    liberar_catalogo(&catalogo);
    liberar_historial(&historial);
    return 0;
}
