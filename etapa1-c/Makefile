# Makefile - CEmestre Etapa 1
#
# Objetivos:
#   make        -> compila bin/cemestre
#   make run    -> compila y ejecuta con las rutas por defecto
#   make clean  -> borra build/ y bin/
#
# Usa cJSON (lib/cjson/) para leer/escribir los archivos JSON del proyecto.
# Ver lib/cjson/README.md para la atribucion/licencia.

CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -Iinclude -Ilib/cjson -g
SRC = $(wildcard src/*.c)
OBJ = $(SRC:src/%.c=build/%.o) build/cJSON.o
BIN = bin/cemestre

.PHONY: all run clean

all: $(BIN)

$(BIN): $(OBJ)
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $(OBJ)

build/%.o: src/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c -o $@ $<

# cJSON es codigo de terceros: se compila sin -Wall/-Wextra para no mezclar
# sus warnings con los del codigo propio del equipo.
build/cJSON.o: lib/cjson/cJSON.c
	@mkdir -p build
	$(CC) -std=c11 -Ilib/cjson -g -w -c -o $@ $<

run: all
	./$(BIN)

clean:
	rm -rf build bin
