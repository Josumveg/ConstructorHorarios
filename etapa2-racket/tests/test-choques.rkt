#lang racket

;; Pruebas del modulo de choques (Pablo).
;; Correr: raco test tests/test-choques.rkt
;; Fallan hasta que Pablo implemente src/choques.rkt: son la especificacion.

(require rackunit
         "../src/tipos.rkt"
         "../src/choques.rkt"
         "ejemplos.rkt")

(define (g . bloques) (grupo 1 bloques))

(test-case "bloques: mismo dia y horas que se cruzan"
  (check-true (bloques-se-solapan? (bloque 'L 730 930) (bloque 'L 820 1030))))

(test-case "bloques: mismo dia, uno contiene al otro"
  (check-true (bloques-se-solapan? (bloque 'L 700 1100) (bloque 'L 800 900))))

(test-case "bloques: terminar justo cuando empieza el otro NO es choque"
  (check-false (bloques-se-solapan? (bloque 'L 730 930) (bloque 'L 930 1120))))

(test-case "bloques: mismas horas pero dia distinto NO chocan"
  (check-false (bloques-se-solapan? (bloque 'L 730 930) (bloque 'K 730 930))))

(test-case "bloques: es simetrica"
  (let ([a (bloque 'M 800 950)] [b (bloque 'M 900 1000)])
    (check-equal? (bloques-se-solapan? a b) (bloques-se-solapan? b a))))

(test-case "grupos: choca si UNO de varios bloques se cruza"
  (check-true (grupos-chocan? (g (bloque 'L 700 800) (bloque 'J 1300 1400))
                              (g (bloque 'M 700 800) (bloque 'J 1330 1500)))))

(test-case "grupos: sin ningun bloque en comun"
  (check-false (grupos-chocan? (g (bloque 'L 700 800)) (g (bloque 'K 700 800)))))

(test-case "grupos del mini-catalogo: unico choque es A1 con B1"
  (let ([a1 (first (curso-grupos curso-a))]  [a2 (second (curso-grupos curso-a))]
        [b1 (first (curso-grupos curso-b))]  [b2 (second (curso-grupos curso-b))])
    (check-true  (grupos-chocan? a1 b1))
    (check-false (grupos-chocan? a1 b2))
    (check-false (grupos-chocan? a2 b1))
    (check-false (grupos-chocan? a2 b2))))

(test-case "compatible-con-seleccion?: lista vacia siempre es compatible"
  (check-true (compatible-con-seleccion? (first (curso-grupos curso-a)) '())))

(test-case "compatible-con-seleccion?: falla si choca con CUALQUIERA de los elegidos"
  (let ([a1 (first (curso-grupos curso-a))]
        [b1 (first (curso-grupos curso-b))]
        [c1 (first (curso-grupos curso-c))])
    (check-false (compatible-con-seleccion? b1 (list c1 a1)))
    (check-true  (compatible-con-seleccion? c1 (list a1 b1)))))
