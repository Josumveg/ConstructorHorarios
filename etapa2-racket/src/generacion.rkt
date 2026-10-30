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
;;   (descender opciones elegidas grupos-elegidos)
;;     - sin opciones: si `elegidas` no esta vacia, es UNA combinacion
;;       (un stream de un elemento); si esta vacia, el stream vacio.
;;     - con (opcion curso grupos) al frente, el stream resultante es la
;;       concatenacion perezosa de:
;;         a) NO tomar este curso: (descender resto elegidas grupos-elegidos)
;;         b) tomarlo con cada grupo g de `grupos` QUE SEA COMPATIBLE con
;;            los grupos ya elegidos:
;;            (descender resto (cons (seleccion curso g) elegidas)
;;                             (cons g grupos-elegidos))
;;
;; Arbol de decisiones con el ejemplo de tests/ejemplos.rkt (A1 choca con B1):
;;
;;                          (inicio)
;;            ___________/     |     \___________
;;        sin A              A1                A2
;;       /  |  \          /  |   \          /  |  \
;;   sinB  B1  B2      sinB B1(X) B2     sinB  B1  B2
;;    ...  ...  ...     ...  poda  ...    ...  ...  ...
;;
;; En (X) A1 y B1 chocan: esa rama se corta ahi mismo y NINGUNA combinacion
;; que contenga A1 y B1 (con o sin C) llega a construirse.
;;
;; Poda (criterio extra de grupos de 4): el filtro de compatibilidad esta
;; EN EL PASO (b), antes de bajar un nivel. Un grupo que choca con los ya
;; elegidos no se agrega, asi que toda la rama que colgaria de el nunca se
;; genera, en lugar de generar la combinacion completa y descartarla
;; despues.
;;
;; Pereza: cada rama que no es la primera se pasa como THUNK (una funcion
;; sin argumentos) a `anexar-perezoso`, y solo se llama cuando el stream
;; anterior se agoto. El resto de cada elemento va dentro de `stream-cons`,
;; que no lo evalua hasta que se pida. Por eso pedir la primera combinacion
;; solo recorre un camino del arbol, no el arbol completo.
;;
;; Inmutabilidad: no hay set! ni estructuras mutables. El "estado" de la
;; busqueda (lo que ya se eligio) viaja como argumentos de la recursion:
;; cada rama recibe su propia lista con `cons`, sin tocar la de las demas.

(require "tipos.rkt"
         "choques.rkt")

(provide
 (contract-out
  [armar-combinacion (-> (listof seleccion?) combinacion?)]
  [generar-combinaciones (-> (listof opcion?) (stream/c combinacion?))]))

;; ---------------------------------------------------------------------
;; Funciones publicas
;; ---------------------------------------------------------------------

;; Suma los creditos de las selecciones y arma la combinacion.
;; Las selecciones se guardan en el mismo orden en que llegan.
(define (armar-combinacion selecciones)
  (combinacion selecciones
               (foldl (lambda (s total)
                        (+ (curso-creditos (seleccion-curso s)) total))
                      0
                      selecciones)))

;; Stream perezoso de todas las combinaciones sin choques, descartando una
;; rama apenas se detecta un choque (poda).
(define (generar-combinaciones opciones)
  (descender opciones '() '()))

;; ---------------------------------------------------------------------
;; Funciones auxiliares (privadas)
;; ---------------------------------------------------------------------

;; descender : (listof opcion) (listof seleccion) (listof grupo)
;;             -> (stream combinacion)
;;
;; Acumuladores:
;;   elegidas         : las selecciones de esta rama, en orden INVERSO
;;                      (cons es O(1) al frente; se invierte una sola vez
;;                      al armar la combinacion).
;;   grupos-elegidos  : los mismos grupos de `elegidas`, ya separados, para
;;                      no recalcular (map seleccion-grupo elegidas) en cada
;;                      paso de la poda.
(define (descender opciones elegidas grupos-elegidos)
  (cond
    ;; Caso base 1: se decidio sobre todos los cursos y no se eligio nada.
    [(and (null? opciones) (null? elegidas))
     empty-stream]
    ;; Caso base 2: se decidio sobre todos los cursos: es UNA combinacion.
    [(null? opciones)
     (stream (armar-combinacion (reverse elegidas)))]
    ;; Caso recursivo: decidir sobre el primer curso.
    [else
     (let ([op (first opciones)]
           [resto (rest opciones)])
       (anexar-perezoso
        ;; a) No tomar este curso.
        (descender resto elegidas grupos-elegidos)
        ;; b) Tomarlo con cada grupo compatible (solo si se agota (a)).
        (lambda ()
          (tomar-con-cada-grupo (opcion-curso op) (opcion-grupos op)
                                resto elegidas grupos-elegidos))))]))

;; tomar-con-cada-grupo : curso (listof grupo) (listof opcion)
;;                        (listof seleccion) (listof grupo)
;;                        -> (stream combinacion)
;;
;; Concatenacion perezosa de las ramas "tomar `c` con el grupo g", una por
;; cada g de `grupos`. AQUI ESTA LA PODA: si g choca con algun grupo ya
;; elegido, se salta sin bajar por esa rama.
(define (tomar-con-cada-grupo c grupos resto elegidas grupos-elegidos)
  (cond
    [(null? grupos) empty-stream]
    [(compatible-con-seleccion? (first grupos) grupos-elegidos)
     (anexar-perezoso
      (descender resto
                 (cons (seleccion c (first grupos)) elegidas)
                 (cons (first grupos) grupos-elegidos))
      (lambda ()
        (tomar-con-cada-grupo c (rest grupos) resto elegidas grupos-elegidos)))]
    [else
     ;; Poda: el grupo choca, la rama completa se descarta aqui mismo.
     (tomar-con-cada-grupo c (rest grupos) resto elegidas grupos-elegidos)]))

;; anexar-perezoso : (stream A) (-> (stream A)) -> (stream A)
;;
;; Los elementos de `primero` seguidos de los de (siguiente). El segundo
;; stream llega como thunk y solo se construye cuando `primero` se agota;
;; el resto de cada elemento va en stream-cons, que es perezoso.
;; No se usa stream-append porque es una funcion: evaluaria las dos ramas
;; antes de concatenarlas.
(define (anexar-perezoso primero siguiente)
  (cond
    [(stream-empty? primero) (siguiente)]
    [else
     (stream-cons (stream-first primero)
                  (anexar-perezoso (stream-rest primero) siguiente))]))
