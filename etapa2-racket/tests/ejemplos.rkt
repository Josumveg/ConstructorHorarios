#lang racket

;; Datos de prueba compartidos por todas las suites de tests/.
;;
;; Mini-catalogo armado a mano (no depende de data/), pensado para que el
;; resultado esperado se pueda calcular a mano:
;;
;;   A  3 creditos   grupo 1: L 700-850     grupo 2: K 700-850
;;   B  4 creditos   grupo 1: L 800-950     grupo 2: M 800-950
;;   C  2 creditos   grupo 1: J 1300-1450
;;
;; El UNICO choque es A1 con B1 (lunes, 800-850 en comun).
;;
;; Combinaciones validas (subconjuntos no vacios, un grupo por curso):
;;   un curso:      A(2) + B(2) + C(1)            =  5
;;   dos cursos:    AB(2*2-1) + AC(2) + BC(2)     =  7
;;   tres cursos:   ABC(2*2*1-1)                  =  3
;;   total                                         = 15
;; Con rango de creditos [5, 7]: AB (7 cr) x3 + AC (5 cr) x2 + BC (6 cr) x2 = 7.

(require "../src/tipos.rkt")

(provide curso-a curso-b curso-c
         catalogo-ejemplo
         opciones-ejemplo
         preferencias-ejemplo
         total-sin-choques
         total-en-rango-5-7)

(define (curso-simple codigo creditos grupos)
  (curso codigo creditos (list "Carrera X") grupos #t))

(define curso-a
  (curso-simple "A" 3
                (list (grupo 1 (list (bloque 'L 700 850)))
                      (grupo 2 (list (bloque 'K 700 850))))))

(define curso-b
  (curso-simple "B" 4
                (list (grupo 1 (list (bloque 'L 800 950)))
                      (grupo 2 (list (bloque 'M 800 950))))))

(define curso-c
  (curso-simple "C" 2
                (list (grupo 1 (list (bloque 'J 1300 1450))))))

(define catalogo-ejemplo
  (catalogo (list curso-a curso-b curso-c)))

;; Todos los grupos de cada curso son elegibles.
(define opciones-ejemplo
  (list (opcion curso-a (curso-grupos curso-a))
        (opcion curso-b (curso-grupos curso-b))
        (opcion curso-c (curso-grupos curso-c))))

(define preferencias-ejemplo
  (preferencias (list (interes "A" '(1 2))
                      (interes "B" '(1 2))
                      (interes "C" '(1)))
                5 7))

(define total-sin-choques 15)
(define total-en-rango-5-7 7)
