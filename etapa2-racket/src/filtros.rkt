#lang racket

;; Modulo: Filtros sobre streams (polimorfismo parametrico)
;; Responsable: Sebastian
;; Rubro: Filtrado correcto por rango de creditos (7) + Funcion con
;;        polimorfismo parametrico (8)
;;
;; Aqui vive la funcion con polimorfismo parametrico que pide el
;; requerimiento funcional 5. Debe servir para MAS DE UN TIPO de filtro,
;; no ser una funcion escrita para creditos:
;;
;;   filtrar-flujo : (A -> boolean) x (stream A) -> (stream A)
;;   por-rango     : (A -> real) x real x real   -> (A -> boolean)
;;
;; `A` es una variable de tipo: las funciones no saben ni les importa que
;; son los elementos (combinaciones, numeros, strings...). El contrato
;; `parametric->/c` lo hace cumplir en tiempo de ejecucion: si la funcion
;; intentara inspeccionar un elemento de tipo A (por ejemplo sumarle algo),
;; el contrato falla. Eso es polimorfismo parametrico de verdad, no solo
;; una funcion generica por casualidad.
;;
;; La unica funcion especifica del dominio es `filtrar-por-creditos`, y
;; esta construida COMPONIENDO las genericas: demuestra la reutilizacion.
;;
;; TODO (Sebastian):
;;   - filtrar-flujo: stream-filter con el predicado (tambien se puede
;;     escribir con recursion explicita y stream-cons; lo importante es que
;;     siga siendo PEREZOSO).
;;   - por-rango: devuelve un predicado; (extractor x) debe caer en
;;     [minimo, maximo] (extremos incluidos).
;;   - filtrar-por-creditos: usa por-rango con combinacion-creditos-totales.
;;   - Agregar una segunda aplicacion de filtrar-flujo en las pruebas (ej.
;;     sobre numeros) para evidenciar que no es especifica de combinaciones.
;;   - Sin set!.

(require "tipos.rkt")

(provide
 (contract-out
  [filtrar-flujo
   (parametric->/c [A] (-> (-> A boolean?) (stream/c A) (stream/c A)))]
  [por-rango
   (parametric->/c [A] (-> (-> A real?) real? real? (-> A boolean?)))]
  [filtrar-por-creditos
   (-> preferencias? (stream/c combinacion?) (stream/c combinacion?))]))

;; Los elementos de `flujo` para los que `criterio` devuelve #t, sin
;; evaluar el resto del stream por adelantado.
(define (filtrar-flujo criterio flujo)
  (error 'filtrar-flujo "TODO (Sebastian)"))

;; Predicado: el valor numerico que `extractor` saca de x esta entre
;; `minimo` y `maximo`, ambos incluidos.
(define (por-rango extractor minimo maximo)
  (error 'por-rango "TODO (Sebastian)"))

;; Las combinaciones cuyos creditos totales estan dentro del rango
;; [creditos-min, creditos-max] de las preferencias.
(define (filtrar-por-creditos prefs flujo)
  (error 'filtrar-por-creditos "TODO (Sebastian)"))
