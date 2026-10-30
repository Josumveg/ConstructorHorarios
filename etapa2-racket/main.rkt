#lang racket

;; Punto de entrada de la etapa 2. Integracion de los modulos:
;;
;;   leer catalogo + preferencias  (Jose)
;;     -> construir cursos candidatos     (Pablo)
;;     -> generar combinaciones sin choques, como stream  (Javier, con
;;        choques.rkt de Pablo)
;;     -> filtrar por rango de creditos   (Sebastian)
;;     -> exportar a JSON                 (Sebastian)
;;
;; Uso:
;;   racket main.rkt [catalogo] [preferencias] [salida]
;; Sin argumentos usa las rutas por defecto de abajo.

(require "src/lectura.rkt"
         "src/candidatos.rkt"
         "src/generacion.rkt"
         "src/filtros.rkt"
         "src/exportacion.rkt")

(provide ejecutar)

(define ruta-catalogo-defecto "data/catalogo_salida.json")
(define ruta-preferencias-defecto "data/preferencias.json")
(define ruta-salida-defecto "data/combinaciones.json")

;; Corre el pipeline completo. Nada se materializa en una lista: cada
;; etapa recibe y devuelve un stream.
(define (ejecutar ruta-catalogo ruta-preferencias ruta-salida)
  (let* ([cat (leer-catalogo ruta-catalogo)]
         [prefs (leer-preferencias ruta-preferencias)]
         [opciones (construir-opciones cat prefs)]
         [combinaciones (generar-combinaciones opciones)]
         [validas (filtrar-por-creditos prefs combinaciones)])
    (exportar-combinaciones validas ruta-salida)))

;; El argumento en la posicion `i`, o `defecto` si no se paso.
(define (argumento args i defecto)
  (if (> (length args) i) (list-ref args i) defecto))

(module+ main
  (let* ([args (vector->list (current-command-line-arguments))]
         [ruta-catalogo (argumento args 0 ruta-catalogo-defecto)]
         [ruta-preferencias (argumento args 1 ruta-preferencias-defecto)]
         [ruta-salida (argumento args 2 ruta-salida-defecto)])
    (with-handlers ([exn:fail?
                     (lambda (e)
                       (eprintf "Error: ~a\n" (exn-message e))
                       (exit 1))])
      (ejecutar ruta-catalogo ruta-preferencias ruta-salida)
      (printf "Combinaciones exportadas a ~a\n" ruta-salida))))
