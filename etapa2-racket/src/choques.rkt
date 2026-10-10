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
;; curso") y en el catalogo real casi todos los cursos la tienen en true.
;; Esta etapa necesita saber si DOS GRUPOS CONCRETOS chocan, asi que se
;; compara bloque contra bloque, igual que hace choques.c en la etapa 1.
;;
;; Reglas heredadas de la etapa 1 (ver su README, seccion 4.2):
;;   - Intervalo semiabierto [inicio, fin): terminar a las 9:20 y empezar a
;;     las 9:20 NO es choque.
;;   - Dos bloques solo chocan si son del MISMO dia.
;;   - Solo se comparan grupos de cursos distintos (de un mismo curso se
;;     elige un unico grupo, asi que nunca hay que compararlos entre si).
;;
;; TODO (Pablo):
;;   - bloques-se-solapan?: mismo dia y (and (< inicio-a fin-b) (< inicio-b fin-a)).
;;   - grupos-chocan?: algun bloque de g1 solapa con algun bloque de g2.
;;     Pista: ormap sobre los bloques de g1, con ormap interno sobre los de g2.
;;   - compatible-con-seleccion?: el grupo no choca con NINGUNO de los grupos
;;     ya elegidos. Es la funcion que hace posible la poda.
;;   - Sin set!, sin estructuras mutables.

(require "tipos.rkt")

(provide
 (contract-out
  [bloques-se-solapan? (-> bloque? bloque? boolean?)]
  [grupos-chocan? (-> grupo? grupo? boolean?)]
  [compatible-con-seleccion? (-> grupo? (listof grupo?) boolean?)]))

;; #t si los dos bloques son del mismo dia y sus intervalos se cruzan.
(define (bloques-se-solapan? a b)
  (error 'bloques-se-solapan? "TODO (Pablo)"))

;; #t si algun bloque de g1 se solapa con algun bloque de g2.
(define (grupos-chocan? g1 g2)
  (error 'grupos-chocan? "TODO (Pablo)"))

;; #t si `g` no choca con ninguno de los grupos de `elegidos`.
;; Con `elegidos` vacio devuelve #t.
(define (compatible-con-seleccion? g elegidos)
  (error 'compatible-con-seleccion? "TODO (Pablo)"))
