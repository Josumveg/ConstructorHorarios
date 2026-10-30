#lang racket

;; Modulo: Lectura del catalogo y de las preferencias
;; Responsable: Jose
;;
;; Pasa los dos JSON de entrada (esquema en data/data_doc.md) a los structs
;; de tipos.rkt. Es el unico modulo que trabaja con jsexpr, el resto del
;; programa solo ve structs.
;;
;; Del catalogo solo se leen codigo, creditos, carreras, grupos y
;; matriculable. Lo demas (nombre, requisitos, choca_con_otro, ciclos...)
;; se ignora.

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

;; En el json el dia es un string de un caracter
(define dias-validos '("L" "K" "M" "J" "V" "S"))

;; Campo obligatorio: si no esta, el error dice cual falta
(define (requerido js llave)
  (hash-ref js llave
            (lambda () (error 'lectura "falta el campo ~a" llave))))

;; Lee un archivo json. Si no se puede abrir, esta vacio o esta mal
;; formado, termina con un error que main.rkt puede mostrar tal cual.
(define (leer-json ruta)
  (define js
    (with-handlers ([exn:fail:filesystem?
                     (lambda (e) (error 'lectura "no se pudo abrir ~a" ruta))]
                    [exn:fail?
                     (lambda (e) (error 'lectura "~a no es un json valido" ruta))])
      (call-with-input-file ruta read-json)))
  (if (eof-object? js)
      (error 'lectura "~a esta vacio" ruta)
      js))

(define (leer-catalogo ruta)
  (jsexpr->catalogo (leer-json ruta)))

(define (leer-preferencias ruta)
  (jsexpr->preferencias (leer-json ruta)))

;; {"dia": "M", "hora_inicio": 730, "hora_fin": 920} -> bloque
(define (jsexpr->bloque js)
  (define dia (requerido js 'dia))
  (unless (member dia dias-validos)
    (error 'lectura "dia invalido: ~s" dia))
  (bloque (string->symbol dia)
          (requerido js 'hora_inicio)
          (requerido js 'hora_fin)))

;; {"numero_grupo": 1, "bloques": [...]} -> grupo
(define (jsexpr->grupo js)
  (grupo (requerido js 'numero_grupo)
         (map jsexpr->bloque (hash-ref js 'bloques '()))))

;; carreras y grupos pueden venir vacios, el resto es obligatorio
(define (jsexpr->curso js)
  (curso (requerido js 'codigo)
         (requerido js 'creditos)
         (hash-ref js 'carreras '())
         (map jsexpr->grupo (hash-ref js 'grupos '()))
         (requerido js 'matriculable)))

;; {"cursos": [...], ...} -> catalogo
(define (jsexpr->catalogo js)
  (catalogo (map jsexpr->curso (requerido js 'cursos))))

;; {"codigo": "CE1106", "grupos": [1, 2]} -> interes
(define (jsexpr->interes js)
  (interes (requerido js 'codigo)
           (requerido js 'grupos)))

;; {"creditos_min": n, "creditos_max": n, "intereses": [...]} -> preferencias
(define (jsexpr->preferencias js)
  (preferencias (map jsexpr->interes (requerido js 'intereses))
                (requerido js 'creditos_min)
                (requerido js 'creditos_max)))
