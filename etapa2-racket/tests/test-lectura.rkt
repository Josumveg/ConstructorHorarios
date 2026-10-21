#lang racket

;; Pruebas de lectura (Jose).
;; Correr: raco test tests/test-lectura.rkt
;; Corre desde etapa2-racket/ (las rutas a data/ son relativas).

(require rackunit
         json
         "../src/tipos.rkt"
         "../src/lectura.rkt")

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

(test-case "leer-catalogo: el catalogo real tiene 45 cursos (4 semestres)"
  ;; Actualizar el 45 cuando se reemplace data/catalogo_salida.json por el de 6 semestres.
  (check-equal? (length (catalogo-cursos (leer-catalogo "data/catalogo_salida.json"))) 45))

(test-case "leer-preferencias: el ejemplo trae mas de un grupo por curso"
  (let ([p (leer-preferencias "data/preferencias.json")])
    (check-equal? (preferencias-creditos-min p) 9)
    (check-equal? (preferencias-creditos-max p) 12)
    (check-true (andmap (lambda (i) (> (length (interes-grupos i)) 1))
                        (preferencias-intereses p)))))

(test-case "leer-catalogo: archivo inexistente reporta error"
  (check-exn exn:fail? (lambda () (leer-catalogo "data/no-existe.json"))))
