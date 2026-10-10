# Makefile - CEmestre Etapa 2 (Racket)
#
# Objetivos:
#   make        -> compila los modulos (raco make)
#   make run    -> compila y ejecuta con las rutas por defecto de main.rkt
#   make test   -> corre todas las pruebas de tests/
#   make exe    -> genera el ejecutable bin/cemestre-racket (entregable)
#   make clean  -> borra compiled/ y bin/
#
# Requiere Racket (https://racket-lang.org) con `racket` y `raco` en el PATH.
# En Windows correr desde Git Bash, igual que la etapa 1.

RACKET = racket
RACO = raco

.PHONY: all run test exe clean

all:
	$(RACO) make main.rkt src/*.rkt

run: all
	$(RACKET) main.rkt

test: all
	$(RACO) test tests

exe: all
	@mkdir -p bin
	$(RACO) exe -o bin/cemestre-racket main.rkt

clean:
	rm -rf compiled src/compiled tests/compiled bin
