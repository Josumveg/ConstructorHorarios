# data/

Carpeta para los archivos de entrada y salida del programa. Los 3 archivos
usan **JSON** (decisión del equipo, no solo la salida):

- `catalogo.json`: catálogo de cursos recolectado de la Guía de Horarios del
  TEC (ver sección 4 de
  [../distribucion-tareas-etapa1-cemestre.md](../distribucion-tareas-etapa1-cemestre.md)).
- `historial.json`: historial de cursos aprobados de un estudiante de prueba.
- `catalogo_salida.json`: archivo exportado por el programa, contrato con la
  etapa de Racket.

**Pendiente de equipo:** definir el esquema JSON exacto de `catalogo.json` y
`historial.json` (nombres de campos, cómo se anidan grupos/bloques/
requisitos) antes de que Jose implemente la carga (módulo 1), para que
Pablo, Javier y Sebastian puedan generar sus propios datos de prueba con el
mismo esquema. También hay que decidir cómo se va a parsear/serializar JSON
en C: un parser propio hecho a la medida del esquema, o una librería
liviana de un solo archivo (ej. cJSON) vendorizada en el repo — cualquiera
de las dos debe quedar documentada y justificada en el README de
`etapa1-c/`.

Las rutas por defecto están en [`include/constantes.h`](../include/constantes.h).
