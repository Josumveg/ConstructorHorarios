% Pruebas de las reglas de politica (Pablo).
% Correr desde etapa3-prolog/: swipl -q -g run_tests -t halt tests/test_reglas.pl
% Los ejemplos y sus resultados estan explicados en tests/ejemplos.pl.

:- use_module(library(plunit)).
:- use_module('../src/modelo').
:- use_module('../src/reglas').
:- use_module(ejemplos).

:- begin_tests(reglas, [setup(politica_ejemplo)]).

% ---- Regla 1: balance entre carreras ----

test(balance_una_sola_carrera_pasa_el_maximo) :-
    ejemplo(2, _, Cursos),
    viola_balance(Cursos).

test(balance_equilibrada, [fail]) :-
    ejemplo(1, _, Cursos),
    viola_balance(Cursos).

test(balance_compartidos_reparten_creditos, [fail]) :-
    ejemplo(3, _, Cursos),
    viola_balance(Cursos).

test(creditos_carrera_con_carrera_dada) :-
    ejemplo(3, _, Cursos),
    carrera(ce, Ce),
    creditos_carrera(Cursos, Ce, Creditos),
    Creditos =:= 13 rdiv 2.

test(creditos_carrera_enumera_carreras) :-
    ejemplo(3, _, Cursos),
    findall(Carrera, creditos_carrera(Cursos, Carrera, _), Carreras),
    sort(Carreras, Ordenadas),
    carrera(ce, Ce),
    carrera(pi, Pi),
    sort([Ce, Pi], Ordenadas).

% ---- Regla 2: limite por area ----

test(area_con_tres_cursos) :-
    ejemplo(3, _, Cursos),
    viola_area(Cursos).

test(area_con_dos_cursos_pasa, [fail]) :-
    ejemplo(4, _, Cursos),
    viola_area(Cursos).

% ---- Regla 3: incompatibilidad ----

test(incompatibilidad_con_par) :-
    ejemplo(4, _, Cursos),
    viola_incompatibilidad(Cursos).

test(incompatibilidad_sin_par, [fail]) :-
    ejemplo(1, _, Cursos),
    viola_incompatibilidad(Cursos).

% ---- incompatibles/2 en varios modos ----

test(incompatibles_verifica_un_par) :-
    incompatibles('CI1407', 'CI1106').

test(incompatibles_es_simetrica) :-
    incompatibles('CI1106', 'CI1407').

test(incompatibles_par_no_declarado, [fail]) :-
    incompatibles('CE1106', 'MI2101').

test(incompatibles_de_un_curso, [all(X == ['CI1407'])]) :-
    incompatibles('CI1106', X).

test(incompatibles_enumera_los_pares) :-
    findall(A-B, incompatibles(A, B), Pares),
    length(Pares, 8).

% ---- viola/2 ----

test(viola_con_regla_dada) :-
    ejemplo(4, _, Cursos),
    viola(incompatibilidad, Cursos).

test(viola_enumera_las_reglas_violadas, [all(R == [balance_carreras, limite_area])]) :-
    ejemplo(5, _, Cursos),
    viola(R, Cursos).

test(viola_ninguna_regla, [fail]) :-
    ejemplo(1, _, Cursos),
    viola(_, Cursos).

:- end_tests(reglas).
