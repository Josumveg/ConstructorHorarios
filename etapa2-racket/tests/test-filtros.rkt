#lang racket

;; Pruebas de filtros y polimorfismo parametrico (Sebastian).
;; Correr: raco test tests/test-filtros.rkt

(require rackunit
         "../src/tipos.rkt"
         "../src/filtros.rkt"
         "../src/generacion.rkt"
         "ejemplos.rkt")

;; ---- La MISMA funcion filtrar-flujo con tipos distintos ----

(define (naturales-desde n)
  (stream-cons n (naturales-desde (add1 n))))

(test-case "filtrar-flujo sobre numeros"
  (check-equal? (stream->list (filtrar-flujo even? (stream 0 1 2 3 4 5 6 7 8 9)))
                '(0 2 4 6 8)))

(test-case "filtrar-flujo sobre strings"
  (check-equal? (stream->list
                 (filtrar-flujo (lambda (s) (> (string-length s) 2))
                                (stream "a" "abc" "hola" "no")))
                '("abc" "hola")))

(test-case "filtrar-flujo sobre combinaciones"
  (let* ([todas (generar-combinaciones opciones-ejemplo)]
         [grandes (filtrar-flujo (lambda (c) (> (length (combinacion-selecciones c)) 2))
                                 todas)])
    (check-equal? (length (stream->list grandes)) 3)))

(test-case "filtrar-flujo es perezoso: funciona sobre un stream infinito"
  (check-equal? (stream->list (stream-take (filtrar-flujo even? (naturales-desde 0)) 3))
                '(0 2 4)))

;; ---- por-rango ----

(test-case "por-rango incluye ambos extremos"
  (let ([p (por-rango values 5 7)])
    (check-false (p 4)) (check-true (p 5)) (check-true (p 7)) (check-false (p 8))))

(test-case "por-rango con otro extractor (largo de un string)"
  (check-true  ((por-rango string-length 2 3) "abc"))
  (check-false ((por-rango string-length 2 3) "abcd")))

;; ---- Filtro de creditos ----

(test-case "filtrar-por-creditos deja solo las del rango [5, 7]"
  (let ([validas (stream->list
                  (filtrar-por-creditos preferencias-ejemplo
                                        (generar-combinaciones opciones-ejemplo)))])
    (check-equal? (length validas) total-en-rango-5-7)
    (check-true (andmap (lambda (c) (<= 5 (combinacion-creditos-totales c) 7)) validas))))

(test-case "filtrar-por-creditos: rango imposible deja el stream vacio"
  (check-equal? (stream->list
                 (filtrar-por-creditos (preferencias '() 100 200)
                                       (generar-combinaciones opciones-ejemplo)))
                '()))
