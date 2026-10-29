#lang racket

(require rackunit
         json
         racket/stream
         "../src/tipos.rkt"
         "../src/filtros.rkt"
         "../src/exportacion.rkt"
         "ejemplos.rkt")

(define seleccion-a
  (seleccion curso-a (first (curso-grupos curso-a))))

(define seleccion-b
  (seleccion curso-b (second (curso-grupos curso-b))))

(define seleccion-c
  (seleccion curso-c (first (curso-grupos curso-c))))

(define combinacion-a
  (combinacion (list seleccion-a) 3))

(define combinacion-ac
  (combinacion (list seleccion-a seleccion-c) 5))

(define combinacion-ab
  (combinacion (list seleccion-a seleccion-b) 7))

(define combinacion-abc
  (combinacion
   (list seleccion-a seleccion-b seleccion-c)
   9))

(define (naturales-desde n)
  (stream-cons n (naturales-desde (add1 n))))

(define (con-json-exportado flujo comprobar)
  (let ([ruta (make-temporary-file "sebastian-~a.json")])
    (dynamic-wind
     void
     (lambda ()
       (exportar-combinaciones flujo ruta)
       (comprobar (call-with-input-file ruta read-json)))
     (lambda ()
       (delete-file ruta)))))

(test-case "Filtro generico con numeros y textos"
  (check-equal?
   (stream->list
    (filtrar-flujo even? (stream 1 2 3 4 5 6)))
   '(2 4 6))

  (check-equal?
   (stream->list
    (filtrar-flujo
     (lambda (texto) (> (string-length texto) 2))
     (stream "a" "abc" "hola")))
   '("abc" "hola")))

(test-case "Filtro perezoso sobre un stream infinito"
  (check-equal?
   (stream->list
    (stream-take
     (filtrar-flujo even? (naturales-desde 0))
     3))
   '(0 2 4)))

(test-case "Rango inclusivo con distintos extractores"
  (let ([criterio (por-rango values 5 7)])
    (check-false (criterio 4))
    (check-true (criterio 5))
    (check-true (criterio 7))
    (check-false (criterio 8)))

  (check-true
   ((por-rango string-length 2 3) "abc"))

  (check-false
   ((por-rango string-length 2 3) "abcd")))

(test-case "Filtro de creditos incluye minimo y maximo"
  (check-equal?
   (stream->list
    (filtrar-por-creditos
     (preferencias '() 5 7)
     (stream combinacion-a
             combinacion-ac
             combinacion-ab
             combinacion-abc)))
   (list combinacion-ac combinacion-ab)))

(test-case "Rango imposible y stream vacio"
  (check-true
   (stream-empty?
    (filtrar-por-creditos
     (preferencias '() 100 200)
     (stream combinacion-a combinacion-ab))))

  (check-true
   (stream-empty?
    (filtrar-por-creditos
     (preferencias '() 0 20)
     empty-stream))))

(test-case "Conversion conserva los campos acordados"
  (let* ([js (combinacion->jsexpr combinacion-ab)]
         [selecciones (hash-ref js 'selecciones)]
         [primera (first selecciones)])
    (check-equal? (hash-ref js 'creditos_totales) 7)
    (check-equal? (length selecciones) 2)
    (check-equal? (hash-ref primera 'curso) "A")
    (check-equal? (hash-ref primera 'grupo) 1)
    (check-equal? (hash-ref primera 'carreras)
                  '("Carrera X"))
    (check-equal? (hash-ref primera 'creditos) 3)
    (check-equal?
     (hash-ref primera 'bloques)
     (list
      (hasheq 'dia "L"
              'hora_inicio 700
              'hora_fin 850)))))

(test-case "Exportacion vacia"
  (con-json-exportado
   empty-stream
   (lambda (js)
     (check-equal? (hash-ref js 'combinaciones) '()))))

(test-case "Exportacion de una combinacion"
  (con-json-exportado
   (stream combinacion-a)
   (lambda (js)
     (check-equal?
      (hash-ref js 'combinaciones)
      (list (combinacion->jsexpr combinacion-a))))))

(test-case "Exportacion de varias combinaciones"
  (con-json-exportado
   (stream combinacion-a combinacion-ab)
   (lambda (js)
     (check-equal?
      (hash-ref js 'combinaciones)
      (list (combinacion->jsexpr combinacion-a)
            (combinacion->jsexpr combinacion-ab))))))