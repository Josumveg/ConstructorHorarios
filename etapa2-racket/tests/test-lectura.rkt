#lang racket

;; Pruebas de lectura (Jose).
;; Correr: raco test tests/test-lectura.rkt

(require rackunit
         json
         racket/runtime-path
         "../src/tipos.rkt"
         "../src/lectura.rkt")

;; rutas relativas a este archivo, asi sirven desde cualquier carpeta
(define-runtime-path ruta-catalogo "../data/catalogo_salida.json")
(define-runtime-path ruta-preferencias "../data/preferencias.json")
(define-runtime-path ruta-inexistente "../data/no-existe.json")

(test-case "jsexpr->bloque: convierte el dia string a simbolo"
  (check-equal? (jsexpr->bloque (hasheq 'dia "M" 'hora_inicio 730 'hora_fin 920))
                (bloque 'M 730 920)))

(test-case "jsexpr->bloque: rechaza un dia invalido"
  (check-exn exn:fail?
             (lambda () (jsexpr->bloque (hasheq 'dia "X" 'hora_inicio 730 'hora_fin 920)))))

(test-case "jsexpr->curso: lee las carreras (una o ambas)"
  (let ([una (jsexpr->curso (hasheq 'codigo "A1" 'nombre "Curso" 'creditos 3
                                    'carreras '("Carrera X")
                                    'grupos '() 'matriculable #t))]
        [ambas (jsexpr->curso (hasheq 'codigo "A2" 'nombre "Curso" 'creditos 3
                                      'carreras '("Carrera X" "Carrera Y")
                                      'grupos '() 'matriculable #t))])
    (check-equal? (curso-carreras una) '("Carrera X"))
    (check-equal? (curso-carreras ambas) '("Carrera X" "Carrera Y"))))

(test-case "jsexpr->curso: falta un campo obligatorio"
  (check-exn exn:fail? (lambda () (jsexpr->curso (hasheq 'nombre "Sin codigo" 'creditos 3)))))

(test-case "leer-catalogo: trae todos los cursos del json"
  (let ([js (call-with-input-file ruta-catalogo read-json)])
    (check-equal? (length (catalogo-cursos (leer-catalogo ruta-catalogo)))
                  (length (hash-ref js 'cursos)))))

(test-case "leer-preferencias: el ejemplo trae mas de un grupo por curso"
  (let ([p (leer-preferencias ruta-preferencias)])
    (check-equal? (preferencias-creditos-min p) 9)
    (check-equal? (preferencias-creditos-max p) 12)
    (check-true (andmap (lambda (i) (> (length (interes-grupos i)) 1))
                        (preferencias-intereses p)))))

(test-case "leer-catalogo: archivo inexistente reporta error"
  (check-exn exn:fail? (lambda () (leer-catalogo ruta-inexistente))))

(test-case "leer-catalogo: un json mal formado reporta error"
  (let ([ruta (make-temporary-file "malo-~a.json")])
    (dynamic-wind
     void
     (lambda ()
       (call-with-output-file ruta #:exists 'truncate
         (lambda (out) (write-string "{\"cursos\": [" out)))
       (check-exn exn:fail? (lambda () (leer-catalogo ruta))))
     (lambda () (delete-file ruta)))))
