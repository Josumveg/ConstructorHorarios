# cJSON (vendorizado)

`cJSON.h` / `cJSON.c` son una copia sin modificar de
[cJSON](https://github.com/DaveGamble/cJSON) de Dave Gamble y colaboradores,
descargada de la rama `master` del repositorio oficial. Licencia MIT (ver
[`LICENSE`](LICENSE)).

## Por qué se usa

El proyecto decidió que catálogo, historial y salida se manejan como JSON
(ver `data/README.md`). C no trae un parser de JSON en la biblioteca
estándar, y escribir uno propio que maneje bien objetos anidados (curso →
grupos → bloques, arreglos de requisitos/correquisitos) es un esfuerzo
considerable frente al tiempo disponible para la etapa. cJSON es una
librería pequeña (un solo `.h`/`.c`, sin dependencias), ampliamente usada en
proyectos C reales, lo que la hace apropiada para vendorizar en vez de
reimplementar un parser desde cero.

## Cómo se usa en el proyecto

- Se compila junto con el resto del código (ver la regla `build/cJSON.o` en
  el `Makefile` de `etapa1-c/`), sin `-Wall -Wextra` porque es código de
  terceros que no se va a modificar.
- `carga.c` (Jose) la usa para parsear `catalogo.json` / `historial.json`.
- `exportacion.c` (Sebastián) la usa para serializar `catalogo_salida.json`.
- API de referencia: <https://github.com/DaveGamble/cJSON#README>.

## Importante

No se debe editar `cJSON.h`/`cJSON.c` — son código de terceros. Si hace
falta una utilidad extra (ej. una función para convertir `BloqueHorario` a
`cJSON*`), esa lógica va en `carga.c`/`exportacion.c`, no aquí.
