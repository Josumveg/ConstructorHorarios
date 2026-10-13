#lang racket

;; Pruebas de la generacion de combinaciones (Javier).
;; Correr: raco test tests/test-generacion.rkt

(require rackunit
         "../src/tipos.rkt"
         "../src/generacion.rkt"
         "../src/choques.rkt"
         "ejemplos.rkt")

;; Una combinacion como lista ordenada de (codigo . grupo), para comparar
;; sin depender del orden en que el stream las produce.
(define (clave c)
  (sort (map (lambda (s) (cons (curso-codigo (seleccion-curso s))
                               (grupo-numero (seleccion-grupo s))))
             (combinacion-selecciones c))
        string<? #:key car))

(define (claves flujo)
  (sort (map clave (stream->list flujo))
        string<? #:key (lambda (k) (format "~a" k))))

(test-case "armar-combinacion: suma los creditos"
  (let ([c (armar-combinacion
            (list (seleccion curso-a (first (curso-grupos curso-a)))
                  (seleccion curso-b (second (curso-grupos curso-b)))))])
    (check-equal? (combinacion-creditos-totales c) 7)))

(test-case "con poda: genera exactamente las 15 combinaciones sin choques"
  (check-equal? (length (stream->list (generar-combinaciones opciones-ejemplo)))
                total-sin-choques))

(test-case "con poda: ninguna combinacion contiene A1 y B1 a la vez"
  (for ([k (in-list (claves (generar-combinaciones opciones-ejemplo)))])
    (check-false (and (member '("A" . 1) k) (member '("B" . 1) k)))))

(test-case "con poda: no hay combinaciones repetidas ni vacias"
  (let ([ks (claves (generar-combinaciones opciones-ejemplo))])
    (check-equal? (length ks) (length (remove-duplicates ks)))
    (check-false (member '() ks))))

(test-case "sin opciones: stream vacio"
  (check-equal? (stream->list (generar-combinaciones '())) '()))

(test-case "es un stream: se puede pedir el primero sin generar todo"
  (check-true (stream? (generar-combinaciones opciones-ejemplo)))
  (check-true (combinacion? (stream-first (generar-combinaciones opciones-ejemplo)))))

(test-case "pereza: con muchos cursos, tomar pocas combinaciones es instantaneo"
  ;; 20 cursos de 3 grupos sin ningun choque = 4^20 (~1 billon) de
  ;; combinaciones. Si generar-combinaciones construyera la lista completa,
  ;; esta prueba no terminaria nunca.
  (let* ([n 20]
         [opciones
          (for/list ([i (in-range n)])
            (let ([c (curso (format "X~a" i) 1 "Carrera X"
                            (for/list ([g (in-range 1 4)])
                              (grupo g (list (bloque 'L (+ 700 (* i 10)) (+ 705 (* i 10))))))
                            #t)])
              (opcion c (curso-grupos c))))])
    (check-equal? (length (stream->list (stream-take (generar-combinaciones opciones) 50)))
                  50)))
