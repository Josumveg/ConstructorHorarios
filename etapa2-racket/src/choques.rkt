#lang racket

;; Modulo: Choques de horario entre grupos
;; Responsable: Pablo
;; Rubro: Generacion correcta de combinaciones sin choques (20)
;;
;; Funciones puras que deciden si dos grupos se cruzan. generacion.rkt las
;; usa para descartar una combinacion APENAS se agrega un grupo que choca
;; (criterio extra de los grupos de 4, "poda").
;;
;; Por que se recalculan aqui y no se reutiliza `choca_con_otro` de C:
;; esa bandera esta a nivel de CURSO ("este curso choca con algun otro
;; curso") y en el catalogo real todos los cursos la tienen en true.
;; Esta etapa necesita saber si DOS GRUPOS CONCRETOS chocan, asi que se
;; compara bloque contra bloque, igual que hace choques.c en la etapa 1.
;;
;; Reglas heredadas de la etapa 1 (ver su README, seccion 4.2):
;;   - Intervalo semiabierto [inicio, fin): terminar a las 9:20 y empezar a
;;     las 9:20 NO es choque.
;;   - Dos bloques solo chocan si son del MISMO dia.
;;   - Solo se comparan grupos de cursos distintos (de un mismo curso se
;;     elige un unico grupo, asi que nunca hay que compararlos entre si).

(require "tipos.rkt")

(provide
 (contract-out
  [bloques-se-solapan? (-> bloque? bloque? boolean?)]
  [grupos-chocan? (-> grupo? grupo? boolean?)]
  [compatible-con-seleccion? (-> grupo? (listof grupo?) boolean?)]))

;; #t si los dos bloques son del mismo dia y sus intervalos se cruzan.
(define (bloques-se-solapan? a b)
  (and
   (eq? (bloque-dia a) (bloque-dia b))
   (< (bloque-inicio a) (bloque-fin b))
   (< (bloque-inicio b) (bloque-fin a))))

;; #t si algun bloque de g1 se solapa con algun bloque de g2.
(define (grupos-chocan? g1 g2)
  (ormap
   (lambda (bloque-g1)
     (ormap
      (lambda (bloque-g2)
        (bloques-se-solapan? bloque-g1 bloque-g2))
      (grupo-bloques g2)))
   (grupo-bloques g1)))

;; #t si `g` no choca con ninguno de los grupos de `elegidos`.
;; Con `elegidos` vacio devuelve #t.
(define (compatible-con-seleccion? g elegidos)
  (not
   (ormap
    (lambda (grupo-elegido)
      (grupos-chocan? g grupo-elegido))
    elegidos)))