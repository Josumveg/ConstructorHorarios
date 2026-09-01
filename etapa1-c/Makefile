# Makefile - CEmestre Etapa 1
#
# Objetivos:
#   make        -> compila bin/cemestre
#   make run    -> compila y ejecuta con las rutas por defecto
#   make clean  -> borra build/ y bin/

CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -Iinclude -g
SRC = $(wildcard src/*.c)
OBJ = $(SRC:src/%.c=build/%.o)
BIN = bin/cemestre

.PHONY: all run clean

all: $(BIN)

$(BIN): $(OBJ)
	@mkdir -p bin
	$(CC) $(CFLAGS) -o $@ $(OBJ)

build/%.o: src/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c -o $@ $<

run: all
	./$(BIN)

clean:
	rm -rf build bin
