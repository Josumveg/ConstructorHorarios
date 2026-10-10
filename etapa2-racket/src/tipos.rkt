#lang racket

;; Modulo: Tipos de datos compartidos
;; Responsable: Jose
;; Rubro: Uso de tipos / contratos (8) + Principios de diseno funcional (12)
;;
;; Equivalente a estructuras.h de la etapa 1: es el contrato de structs
;; contra el que trabajan los cuatro modulos. TODOS los structs son
;; inmutables (sin #:mutable): enunciado, "Aspectos operativos" punto 5.
;;
;; Tipado: se usan CONTRATOS (racket/contract), no Typed Racket. Typed
;; Racket no trae tipos para racket/stream ni para stream-cons, y el
;; enunciado exige streams. Ver README, seccion "Decisiones de diseno".
;; Cada struct se exporta con contract-out, asi que construir un struct
;; con un campo del tipo equivocado falla con un error de contrato.
;;
;; Solo se modelan los campos que esta etapa usa. El resto del JSON de la
;; etapa 1 (nombre, requisitos, correquisitos, choca_con_otro, ciclos...)
;; se ignora al leer.

(provide dia/c hora/c
         (contract-out
          (struct bloque ([dia dia/c] [inicio hora/c] [fin hora/c]))
          (struct grupo ([numero exact-positive-integer?]
                         [bloques (listof bloque?)]))
          (struct curso ([codigo string?]
                         [creditos exact-nonnegative-integer?]
                         [carrera string?]
                         [grupos (listof grupo?)]
                         [matriculable boolean?]))
          (struct catalogo ([cursos (listof curso?)]))
          (struct interes ([codigo string?]
                           [grupos (listof exact-positive-integer?)]))
          (struct preferencias ([intereses (listof interes?)]
                                [creditos-min exact-nonnegative-integer?]
                                [creditos-max exact-nonnegative-integer?]))
          (struct opcion ([curso curso?] [grupos (listof grupo?)]))
          (struct seleccion ([curso curso?] [grupo grupo?]))
          (struct combinacion ([selecciones (listof seleccion?)]
                               [creditos-totales exact-nonnegative-integer?]))))

;; ---- Contratos de campos simples ----

;; 'L lunes, 'K martes, 'M miercoles, 'J jueves, 'V viernes, 'S sabado.
;; Misma convencion que BloqueHorario.dia en la etapa 1 (K = martes porque
;; M ya es miercoles).
(define dia/c (or/c 'L 'K 'M 'J 'V 'S))

;; Hora en formato HHMM como entero (730 = 7:30, 1500 = 15:00), igual que
;; en la etapa 1: comparar con < / > respeta el orden cronologico.
(define hora/c (integer-in 0 2359))

;; ---- Structs (todos inmutables) ----

;; Una franja horaria de un grupo. Intervalo semiabierto [inicio, fin).
(struct bloque (dia inicio fin) #:transparent)

;; Un grupo de un curso. Puede tener varios bloques (ej. martes y jueves).
(struct grupo (numero bloques) #:transparent)

;; Un curso del catalogo exportado por la etapa 1.
;;   carrera      : la carrera que APORTA el curso (campo nuevo de esta etapa).
;;   matriculable : bandera calculada por la etapa 1 (cumple requisitos y
;;                  correquisitos). Es lo que significa "curso habilitado".
;; El `choca_con_otro` de la etapa 1 no se lee: esta a nivel de curso y esta
;; etapa necesita choques entre grupos (ver choques.rkt).
(struct curso (codigo creditos carrera grupos matriculable) #:transparent)

;; El catalogo completo leido de catalogo_salida.json.
(struct catalogo (cursos) #:transparent)

;; Una linea de la lista de interes del estudiante: un curso y los grupos
;; que le interesan. `grupos` vacio = le interesan todos los grupos.
(struct interes (codigo grupos) #:transparent)

;; Contenido de preferencias.json.
(struct preferencias (intereses creditos-min creditos-max) #:transparent)

;; Un curso candidato a entrar en una combinacion, ya reducido a los
;; grupos entre los que se puede elegir. Lo produce candidatos.rkt y lo
;; consume generacion.rkt.
(struct opcion (curso grupos) #:transparent)

;; Un par curso-grupo elegido. Guarda los structs completos (no solo el
;; codigo y el numero) para que la generacion pueda revisar choques
;; y la exportacion pueda escribir creditos, carrera y bloques sin volver
;; a buscar en el catalogo.
(struct seleccion (curso grupo) #:transparent)

;; Una combinacion de horario: los pares elegidos y su total de creditos.
(struct combinacion (selecciones creditos-totales) #:transparent)
