% Pruebas de la razon de rechazo (Javier).
% Correr desde etapa3-prolog/: swipl -q -g run_tests -t halt tests/test_razon.pl
% Los ejemplos y sus resultados estan explicados en tests/ejemplos.pl.

:- use_module(library(plunit)).
:- use_module('../src/modelo').
:- use_module('../src/razon').
:- use_module(ejemplos).

:- begin_tests(razon, [setup(politica_ejemplo)]).

% primera_violacion/2 es determinista: una sola razon por combinacion.
test(razon_balance, [true(R == balance_carreras)]) :-
    ejemplo(2, _, Cursos),
    primera_violacion(Cursos, R).

test(razon_area, [true(R == limite_area)]) :-
    ejemplo(3, _, Cursos),
    primera_violacion(Cursos, R).

test(razon_incompatibilidad, [true(R == incompatibilidad)]) :-
    ejemplo(4, _, Cursos),
    primera_violacion(Cursos, R).

test(sin_razon_si_cumple, [fail]) :-
    ejemplo(1, _, Cursos),
    primera_violacion(Cursos, _).

% La combinacion 5 viola balance Y area: el orden decide la razon.
test(orden_de_la_politica, [true(R == balance_carreras)]) :-
    ejemplo(5, _, Cursos),
    primera_violacion(Cursos, R).

test(orden_balance_primero, [true(R == balance_carreras)]) :-
    ejemplo(5, _, Cursos),
    primera_violacion([balance_carreras, limite_area, incompatibilidad], Cursos, R).

test(orden_area_primero, [true(R == limite_area)]) :-
    ejemplo(5, _, Cursos),
    primera_violacion([limite_area, balance_carreras, incompatibilidad], Cursos, R).

test(cumple_segun_lo_esperado) :-
    forall(( ejemplo(_, Nombre, Cursos), esperado(Nombre, Cumple, _, _) ),
           ( cumple(Cursos) -> Cumple == true ; Cumple == false )).

test(evaluar_cumple, [true(V == cumple)]) :-
    ejemplo(1, _, Cursos),
    evaluar(Cursos, V).

test(evaluar_viola, [true(V == viola(limite_area))]) :-
    ejemplo(3, _, Cursos),
    evaluar(Cursos, V).

:- end_tests(razon).
