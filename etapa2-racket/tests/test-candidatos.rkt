#lang racket

;; Pruebas de la seleccion de candidatos (Pablo).
;; Correr: raco test tests/test-candidatos.rkt

(require rackunit
         "../src/tipos.rkt"
         "../src/candidatos.rkt"
         "ejemplos.rkt")

(define (codigos opciones)
  (map (lambda (o) (curso-codigo (opcion-curso o))) opciones))

(test-case "buscar-curso: existente e inexistente"
  (check-equal? (curso-codigo (buscar-curso catalogo-ejemplo "B")) "B")
  (check-false (buscar-curso catalogo-ejemplo "ZZ9999")))

(test-case "grupos-elegibles: lista de interes restringe los grupos"
  (check-equal? (map grupo-numero (grupos-elegibles curso-a (interes "A" '(2))))
                '(2)))

(test-case "grupos-elegibles: sin grupos de interes no hay grupos elegibles"
  (check-equal? (grupos-elegibles curso-b (interes "B" '())) '()))

(test-case "grupos-elegibles: ignora un grupo de interes que no existe"
  (check-equal? (map grupo-numero (grupos-elegibles curso-a (interes "A" '(2 9))))
                '(2)))

(test-case "construir-opciones: respeta el orden de la lista de interes"
  (check-equal? (codigos (construir-opciones catalogo-ejemplo preferencias-ejemplo))
                '("A" "B" "C")))

(test-case "construir-opciones: descarta cursos no matriculables"
  (let* ([b-no (struct-copy curso curso-b [matriculable #f])]
         [cat (catalogo (list curso-a b-no curso-c))])
    (check-equal? (codigos (construir-opciones cat preferencias-ejemplo))
                  '("A" "C"))))

(test-case "construir-opciones: descarta cursos de interes que no estan en el catalogo"
  (let ([prefs (preferencias (list (interes "A" '(1)) (interes "ZZ9999" '(1))) 1 10)])
    (check-equal? (codigos (construir-opciones catalogo-ejemplo prefs)) '("A"))))

(test-case "construir-opciones: descarta un curso si no le queda ningun grupo"
  (let ([prefs (preferencias (list (interes "C" '(7))) 1 10)])
    (check-equal? (construir-opciones catalogo-ejemplo prefs) '())))

(test-case "construir-opciones: los grupos de la opcion son solo los de interes"
  (let* ([prefs (preferencias (list (interes "A" '(2))) 1 10)]
         [ops (construir-opciones catalogo-ejemplo prefs)])
    (check-equal? (map grupo-numero (opcion-grupos (first ops))) '(2))))
