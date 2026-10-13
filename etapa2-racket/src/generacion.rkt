#lang racket

;; Modulo: Generacion de combinaciones con streams
;; Responsable: Javier
;; Rubro: Generacion correcta (20) + Uso de streams (15) + Principios de
;;        diseno funcional (12) + Optimizacion por poda, grupos de 4 (15)
;;
;; Es el modulo central de la etapa. Recibe la lista de `opcion` que
;; produce candidatos.rkt y devuelve un STREAM de `combinacion`. Un stream
;; calcula cada combinacion solo cuando alguien la pide: nunca se arma la
;; lista completa en memoria (requerimiento funcional 2).
;;
;; Que es una combinacion (decision 2 del README): un SUBCONJUNTO no vacio
;; de los cursos candidatos, con exactamente UN grupo por cada curso
;; incluido, y sin choques entre los grupos elegidos. Se generan
;; subconjuntos (y no siempre todos los cursos) porque asi el filtro por
;; rango de creditos tiene algo que filtrar: si cada combinacion llevara
;; todos los cursos de interes, todas sumarian los mismos creditos.
;;
;; Idea del algoritmo (recursion sobre la lista de opciones, SIN set!):
;;
;;   (descender opciones elegidas)
;;     - sin opciones: si `elegidas` no esta vacia, es UNA combinacion
;;       (un stream de un elemento); si esta vacia, el stream vacio.
;;     - con (opcion curso grupos) al frente, el stream resultante es la
;;       concatenacion de:
;;         a) NO tomar este curso: (descender resto elegidas)
;;         b) tomarlo con cada grupo g de `grupos` QUE SEA COMPATIBLE con
;;            los grupos ya elegidos: (descender resto (cons (seleccion curso g) elegidas))
;;       Cada rama se envuelve en stream-lazy (o stream-cons) para que no
;;       se calcule hasta que se consuma.
;;
;; Poda (criterio extra de grupos de 4): el filtro de compatibilidad esta
;; EN EL PASO (b). Un grupo que choca con los ya elegidos no se agrega,
;; asi que toda la rama que colgaria de el (todas las combinaciones que lo
;; contendrian) nunca se genera, en lugar de generar la combinacion
;; completa y descartarla despues.
;;
;; TODO (Javier):
;;   - armar-combinacion: lista de `seleccion` -> `combinacion` con la suma
;;     de creditos (foldl o apply +).
;;   - generar-combinaciones (con poda) como se describio arriba.
;;   - Verificar la pereza: (stream-first (generar-combinaciones opciones))
;;     debe responder rapido aunque haya millones de combinaciones.
;;   - Sin set!, sin variables globales reasignadas, sin listas mutables.

(require "tipos.rkt"
         "choques.rkt")

(provide
 (contract-out
  [armar-combinacion (-> (listof seleccion?) combinacion?)]
  [generar-combinaciones (-> (listof opcion?) (stream/c combinacion?))]))

;; Suma los creditos de las selecciones y arma la combinacion.
(define (armar-combinacion selecciones)
  (error 'armar-combinacion "TODO (Javier)"))

;; Stream perezoso de todas las combinaciones sin choques, descartando una
;; rama apenas se detecta un choque (poda).
(define (generar-combinaciones opciones)
  (error 'generar-combinaciones "TODO (Javier)"))
