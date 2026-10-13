#lang racket

;; Modulo: Lectura del catalogo y de las preferencias
;; Responsable: Jose
;; Rubro: Requerimiento funcional 1 (leer el catalogo de C) + Uso de tipos (8)
;;
;; Convierte los dos JSON de entrada (esquema en data/data_doc.md) en
;; structs de tipos.rkt. Es el unico modulo que toca jsexpr: de aqui en
;; adelante todo el programa trabaja con structs.
;;
;; Convenciones de este modulo:
;;   - Funciones puras salvo las dos que abren archivos.
;;   - Un JSON mal formado o con un campo obligatorio ausente se reporta
;;     con (error ...) y un mensaje que nombre el archivo y el campo.
;;     main.rkt captura esos errores; el programa no debe "tronar" con una
;;     traza larga.
;;
;; TODO (Jose):
;;   - Leer los archivos con (call-with-input-file ruta read-json).
;;   - dia: el JSON trae un string de 1 caracter ("M"); convertirlo al
;;     simbolo correspondiente ('M). Rechazar cualquier otro valor.
;;   - carrera: usar el campo "carrera" del curso si existe; si el JSON aun
;;     no lo trae (catalogo viejo), usar el primer elemento de "carreras".
;;     Asi el modulo funciona antes y despues del cambio en C.
;;   - matriculable es un booleano JSON (#t / #f). `grupos` puede venir vacio.
;;   - Ignorar (sin fallar) el resto de campos: nombre, requisitos,
;;     correquisitos, choca_con_otro, ciclos, hay_ciclos.

(require json
         "tipos.rkt")

(provide
 (contract-out
  [leer-catalogo (-> path-string? catalogo?)]
  [leer-preferencias (-> path-string? preferencias?)]
  [jsexpr->bloque (-> jsexpr? bloque?)]
  [jsexpr->grupo (-> jsexpr? grupo?)]
  [jsexpr->curso (-> jsexpr? curso?)]
  [jsexpr->catalogo (-> jsexpr? catalogo?)]
  [jsexpr->preferencias (-> jsexpr? preferencias?)]))

;; Lee `catalogo_salida.json` (salida de la etapa 1) y devuelve el catalogo.
(define (leer-catalogo ruta)
  (error 'leer-catalogo "TODO (Jose): leer ~a con read-json y llamar a jsexpr->catalogo" ruta))

;; Lee `preferencias.json` y devuelve las preferencias del estudiante.
(define (leer-preferencias ruta)
  (error 'leer-preferencias "TODO (Jose): leer ~a con read-json y llamar a jsexpr->preferencias" ruta))

;; {"dia": "M", "hora_inicio": 730, "hora_fin": 920} -> bloque
(define (jsexpr->bloque js)
  (error 'jsexpr->bloque "TODO (Jose)"))

;; {"numero_grupo": 1, "bloques": [...]} -> grupo
(define (jsexpr->grupo js)
  (error 'jsexpr->grupo "TODO (Jose)"))

;; Objeto de curso (con o sin "carrera") -> curso
(define (jsexpr->curso js)
  (error 'jsexpr->curso "TODO (Jose)"))

;; {"cursos": [...], ...} -> catalogo
(define (jsexpr->catalogo js)
  (error 'jsexpr->catalogo "TODO (Jose)"))

;; {"creditos_min": n, "creditos_max": n, "intereses": [...]} -> preferencias
(define (jsexpr->preferencias js)
  (error 'jsexpr->preferencias "TODO (Jose)"))
