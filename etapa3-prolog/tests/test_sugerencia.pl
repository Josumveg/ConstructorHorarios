% Pruebas del curso a quitar, criterio de grupos de 4 (Javier).
% Correr desde etapa3-prolog/: swipl -q -g run_tests -t halt tests/test_sugerencia.pl
% Los ejemplos y sus resultados estan explicados en tests/ejemplos.pl.

:- use_module(library(plunit)).
:- use_module('../src/modelo').
:- use_module('../src/sugerencia').
:- use_module(ejemplos).

:- begin_tests(sugerencia, [setup(politica_ejemplo)]).

test(quitar_un_curso_de_area, [true(Q == ['FI1201'])]) :-
    ejemplo(3, _, Cursos),
    cursos_a_quitar(Cursos, Q).

test(quitar_cualquiera_de_un_par_incompatible, [true(Q == ['CI1407', 'CI1106'])]) :-
    ejemplo(4, _, Cursos),
    cursos_a_quitar(Cursos, Q).

test(ningun_curso_la_arregla, [true(Q == [])]) :-
    ejemplo(2, _, Cursos),
    cursos_a_quitar(Cursos, Q).

test(combinacion_que_ya_cumple, [true(Q == [])]) :-
    ejemplo(1, _, Cursos),
    cursos_a_quitar(Cursos, Q).

test(coincide_con_lo_esperado) :-
    forall(( ejemplo(_, Nombre, Cursos), esperado(Nombre, _, _, Esperados) ),
           ( cursos_a_quitar(Cursos, Q), Q == Esperados )).

% Quitar el unico curso dejaria la combinacion vacia: no cuenta.
test(un_solo_curso_no_se_vacia, [true(Q == [])]) :-
    carrera(ce, Ce),
    cursos_a_quitar([curso('CE1106', 1, 3, [Ce], computacion)], Q).

:- end_tests(sugerencia).
