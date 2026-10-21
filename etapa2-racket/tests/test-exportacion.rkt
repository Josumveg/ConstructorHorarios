#lang racket

;; Pruebas de la exportacion (Sebastian).
;; Correr: raco test tests/test-exportacion.rkt

(require rackunit
         json
         "../src/tipos.rkt"
         "../src/exportacion.rkt"
         "../src/generacion.rkt"
         "ejemplos.rkt")

(define a1 (first (curso-grupos curso-a)))
(define b2 (second (curso-grupos curso-b)))

(define combinacion-ab
  (armar-combinacion (list (seleccion curso-a a1) (seleccion curso-b b2))))

(test-case "combinacion->jsexpr: los tres campos minimos del enunciado"
  (let ([js (combinacion->jsexpr combinacion-ab)])
    (check-equal? (hash-ref js 'creditos_totales) 7)
    (let ([sels (hash-ref js 'selecciones)])
      (check-equal? (length sels) 2)
      (check-equal? (hash-ref (first sels) 'curso) "A")
      (check-equal? (hash-ref (first sels) 'grupo) 1)
      (check-equal? (hash-ref (first sels) 'carreras) '("Carrera X")))))

(test-case "combinacion->jsexpr: creditos del curso en cada seleccion"
  (let ([sels (hash-ref (combinacion->jsexpr combinacion-ab) 'selecciones)])
    (check-equal? (hash-ref (first sels) 'creditos) 3)
    (check-equal? (hash-ref (second sels) 'creditos) 4)))

(test-case "combinacion->jsexpr: bloques del grupo, con el dia como string"
  (let* ([sels (hash-ref (combinacion->jsexpr combinacion-ab) 'selecciones)]
         [bloques-a (hash-ref (first sels) 'bloques)])
    (check-equal? bloques-a
                  (list (hasheq 'dia "L" 'hora_inicio 700 'hora_fin 850)))))

(test-case "exportar-combinaciones: escribe JSON valido con todas las combinaciones"
  (let ([ruta (make-temporary-file "combinaciones-~a.json")])
    (dynamic-wind
     void
     (lambda ()
       (exportar-combinaciones (generar-combinaciones opciones-ejemplo) ruta)
       (let ([js (call-with-input-file ruta read-json)])
         (check-equal? (length (hash-ref js 'combinaciones)) total-sin-choques)))
     (lambda () (delete-file ruta)))))

(test-case "exportar-combinaciones: stream vacio produce un JSON valido"
  (let ([ruta (make-temporary-file "combinaciones-~a.json")])
    (dynamic-wind
     void
     (lambda ()
       (exportar-combinaciones empty-stream ruta)
       (check-equal? (hash-ref (call-with-input-file ruta read-json) 'combinaciones)
                     '()))
     (lambda () (delete-file ruta)))))
