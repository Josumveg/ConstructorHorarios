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
;; filtrar-flujo reutiliza el mismo algoritmo con distintos tipos de
;; elementos y criterios. Su contrato verifica el predicado y los streams.
;; por-rango conserva el contrato parametrico: recibe un extractor que
;; obtiene un numero de un elemento de tipo A y devuelve un predicado
;; para elementos del mismo tipo.
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

(require racket/contract
         racket/stream
         "tipos.rkt")

(provide
 (contract-out
  [filtrar-flujo
   (-> (-> any/c boolean?) stream? stream?)]
  [por-rango
   (parametric->/c [A] (-> (-> A real?) real? real? (-> A boolean?)))]
  [filtrar-por-creditos
   (-> preferencias? (stream/c combinacion?) (stream/c combinacion?))]))

;; Los elementos de `flujo` para los que `criterio` devuelve #t, sin
;; evaluar el resto del stream por adelantado.
(define (filtrar-flujo criterio flujo)
  (stream-filter criterio flujo))

;; Predicado: el valor numerico que `extractor` saca de x esta entre
;; `minimo` y `maximo`, ambos incluidos.
(define (por-rango extractor minimo maximo)
  (lambda (elemento)
    (<= minimo (extractor elemento) maximo)))

;; Las combinaciones cuyos creditos totales estan dentro del rango
;; [creditos-min, creditos-max] de las preferencias.
(define (filtrar-por-creditos prefs flujo)
  (filtrar-flujo
   (por-rango combinacion-creditos-totales
              (preferencias-creditos-min prefs)
              (preferencias-creditos-max prefs))
   flujo))
