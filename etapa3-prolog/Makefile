# Makefile - CEmestre Etapa 3 (Prolog)
#
# Objetivos:
#   make        -> carga main.pl y los modulos sin ejecutar nada (revisa sintaxis)
#   make run    -> ejecuta con las rutas por defecto de main.pl
#   make test   -> corre todas las pruebas de tests/ (plunit)
#
# Requiere SWI-Prolog (https://www.swi-prolog.org) con `swipl` en el PATH.
# En Windows correr desde Git Bash, igual que las etapas anteriores.
# Las pruebas se corren desde esta carpeta (usan rutas relativas a data/).

SWIPL = swipl

.PHONY: all run test

all:
	$(SWIPL) -q -g "consult('src/modelo'),consult('src/carga'),consult('src/reglas'),consult('src/razon'),consult('src/sugerencia'),consult('src/evaluacion'),consult('src/exportacion')" -t halt

run:
	$(SWIPL) main.pl

test:
	@for t in tests/test_*.pl; do \
	  echo "== $$t"; \
	  $(SWIPL) -q -g run_tests -t halt $$t || exit 1; \
	done
