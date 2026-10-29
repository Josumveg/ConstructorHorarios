#lang racket

;; Modulo: Exportacion de las combinaciones a JSON
;; Responsable: Sebastian
;; Rubro: Requerimiento funcional 6 + README, justificacion del formato (15)
;;
;; Escribe el archivo que va a leer la etapa 3 (Prolog). El esquema esta en
;; data/data_doc.md; es un CONTRATO con Prolog, asi que cualquier cambio se
;; avisa al equipo.
;;
;; Por cada combinacion contiene los tres campos minimos que exige el
;; enunciado (pares curso-grupo, creditos totales y carrera de origen de
;; cada curso, en `carreras`) y, por cada seleccion, DOS campos extra: `creditos` y
;; `bloques`. Se agregan porque el archivo es lo unico que lee Prolog
;; (etapa 3) y esta etapa no se vuelve a modificar: con `creditos` Prolog
;; puede sumar creditos por carrera, y con `bloques` aplicar reglas de
;; horario sin releer el catalogo. Justificacion en el README, seccion 2.3.
;;
;;   {
;;     "combinaciones": [
;;       { "selecciones": [
;;           { "curso": "CE1106", "grupo": 1, "carreras": ["Ingenieria en Computadores"],
;;             "creditos": 3,
;;             "bloques": [ {"dia": "K", "hora_inicio": 1700, "hora_fin": 1850} ] }
;;         ],
;;         "creditos_totales": 3 }
;;     ]
;;   }
;;
;; Escritura INCREMENTAL: cada combinacion se escribe en cuanto el stream la
;; produce. NO convertir el stream a lista (stream->list) para exportar, eso
;; anularia el beneficio de usar streams.
;;
;; TODO (Sebastian):
;;   - combinacion->jsexpr: funcion pura, facil de probar sin tocar disco.
;;     Las claves de un jsexpr son simbolos: (hasheq 'curso "CE1106" ...).
;;     El dia de cada bloque es un simbolo ('K): escribirlo como string
;;     de 1 caracter ("K"), igual que en el catalogo de entrada.
;;   - exportar-combinaciones: abrir el archivo con call-with-output-file
;;     #:exists 'truncate, escribir el inicio del arreglo, recorrer el stream
;;     (for sobre in-stream) escribiendo cada combinacion con write-json y
;;     una coma ENTRE elementos (no despues del ultimo), y cerrar el
;;     arreglo. Sin set!: para saber si hay que poner coma, usar for/fold
;;     con un acumulador "es la primera".
;;   - Si el stream queda vacio, el archivo debe seguir siendo JSON valido
;;     ("combinaciones": []).
;;   - Justificar el formato JSON en el README (seccion 2.3).

(require json
         racket/contract
         racket/stream
         "tipos.rkt")

(provide
 (contract-out
  [combinacion->jsexpr (-> combinacion? jsexpr?)]
  [exportar-combinaciones (-> (stream/c combinacion?) path-string? void?)]))

;; Convierte una combinacion al objeto JSON descrito arriba.
(define (combinacion->jsexpr c)
  (define (bloque->jsexpr b)
    (hasheq
     'dia (symbol->string (bloque-dia b))
     'hora_inicio (bloque-inicio b)
     'hora_fin (bloque-fin b)))

  (define (seleccion->jsexpr s)
    (let ([curso-elegido (seleccion-curso s)]
          [grupo-elegido (seleccion-grupo s)])
      (hasheq
       'curso (curso-codigo curso-elegido)
       'grupo (grupo-numero grupo-elegido)
       'carreras (curso-carreras curso-elegido)
       'creditos (curso-creditos curso-elegido)
       'bloques
       (map bloque->jsexpr
            (grupo-bloques grupo-elegido)))))

  (hasheq
   'selecciones
   (map seleccion->jsexpr (combinacion-selecciones c))
   'creditos_totales
   (combinacion-creditos-totales c)))

;; Escribe en `ruta` todas las combinaciones del stream. Consume el stream
;; una sola vez.
(define (exportar-combinaciones flujo ruta)
  (call-with-output-file ruta
    (lambda (salida)
      (display "{\"combinaciones\": [\n" salida)

      (for/fold ([primera? #t])
                ([c (in-stream flujo)])
        (unless primera?
          (display ",\n" salida))

        (write-json (combinacion->jsexpr c)
                    salida
                    #:indent 2)
        #f)

      (display "\n]}\n" salida))
    #:exists 'truncate))
