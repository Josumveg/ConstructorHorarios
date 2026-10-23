#lang racket

;; Modulo: Seleccion de cursos candidatos
;; Responsable: Pablo
;; Rubro: Generacion correcta de combinaciones sin choques (20)
;;
;; Cruza el catalogo con las preferencias del estudiante y produce la
;; lista de `opcion` (curso + grupos elegibles) sobre la que trabaja
;; generacion.rkt. Es el "filtro de entrada" del pipeline:
;;
;;   catalogo + preferencias  --construir-opciones-->  (listof opcion)
;;
;; Un curso entra como candidato solo si cumple las tres condiciones:
;;   1. Esta en la lista de interes del estudiante (preferencias.json).
;;   2. Esta habilitado: `matriculable` es #t en el catalogo de la etapa 1
;;      (cumple requisitos y correquisitos; ya esta calculado, no se
;;      recalcula aqui: "No debe modificarse la logica de requisitos").
;;   3. Le queda al menos un grupo elegible.
;;
;; Sus grupos elegibles son los grupos del catalogo cuyo numero aparece en
;; los grupos de interes de ese curso. Un grupo de interes que no existe en
;; el catalogo se ignora. Un curso sin grupos elegibles no entra.
;; Los cursos de interes que no existen en el catalogo o no son
;; matriculables tambien se ignoran, sin mensaje.
;;
;; TODO (Pablo):
;;   - buscar-curso: encontrar un curso por codigo en el catalogo.
;;   - grupos-elegibles: aplicar la regla de grupos de interes.
;;   - construir-opciones: combinar lo anterior; conserva el orden de la
;;     lista de interes.
;;   - Sin set!; usar filter-map / for/list.

(require "tipos.rkt")

(provide
 (contract-out
  [buscar-curso (-> catalogo? string? (or/c curso? #f))]
  [grupos-elegibles (-> curso? interes? (listof grupo?))]
  [construir-opciones (-> catalogo? preferencias? (listof opcion?))]))

;; El curso del catalogo con ese codigo, o #f si no existe.
(define (buscar-curso cat codigo)
  (findf
   (lambda (c)
     (string=? (curso-codigo c) codigo))
   (catalogo-cursos cat)))

;; Los grupos de `c` cuyo numero esta en (interes-grupos i).
(define (grupos-elegibles c i)
  (filter
   (lambda (g)
     (member (grupo-numero g)
             (interes-grupos i)))
   (curso-grupos c)))

;; Una `opcion` por cada curso de interes que sea candidato valido.
(define (construir-opciones cat prefs)
  (filter-map
   (lambda (i)
     (define c (buscar-curso cat (interes-codigo i)))
     (cond
       [(not c)
        #f]
       [(not (curso-matriculable c))
        #f]
       [else
        (define grupos (grupos-elegibles c i))
        (if (empty? grupos)
            #f
            (opcion c grupos))]))
   (preferencias-intereses prefs)))