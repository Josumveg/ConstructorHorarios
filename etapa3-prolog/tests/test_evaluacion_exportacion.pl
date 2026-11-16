% Pruebas del recorrido y la exportacion (Sebastian).
% Correr desde etapa3-prolog/: swipl -q -g run_tests -t halt tests/test_evaluacion_exportacion.pl
% Los ejemplos y sus resultados estan explicados en tests/ejemplos.pl.

:- use_module(library(plunit)).
:- use_module(library(http/json)).
:- use_module('../src/modelo').
:- use_module('../src/evaluacion').
:- use_module('../src/exportacion').
:- use_module(ejemplos).

% Estas pruebas no usan carga.pl: dejan los ejemplos como hechos
% combinacion/2 por su cuenta (el assertz es solo de la prueba).
cargar_ejemplos :-
    forall(ejemplo(Id, _, Cursos), assertz(modelo:combinacion(Id, Cursos))).

limpiar_ejemplos :-
    retractall(modelo:combinacion(_, _)).

:- begin_tests(evaluacion,
               [ setup((politica_ejemplo, cargar_ejemplos)),
                 cleanup(limpiar_ejemplos) ]).

test(evaluar_combinacion_que_cumple) :-
    ejemplo(1, _, Cursos),
    evaluar_combinacion(combinacion(1, Cursos),
                        resultado(1, Cursos, true, ninguna, [])).

test(evaluar_combinacion_rechazada) :-
    ejemplo(3, _, Cursos),
    evaluar_combinacion(combinacion(3, Cursos),
                        resultado(3, Cursos, false, limite_area, ['FI1201'])).

test(evaluar_todas_recorre_las_cinco) :-
    evaluar_todas(Resultados),
    findall(Id, member(resultado(Id, _, _, _, _), Resultados), Ids),
    Ids == [1, 2, 3, 4, 5].

test(evaluar_todas_coincide_con_lo_esperado) :-
    evaluar_todas(Resultados),
    forall(( ejemplo(Id, Nombre, _), esperado(Nombre, Cumple, Razon, Quitar) ),
           memberchk(resultado(Id, _, Cumple, Razon, Quitar), Resultados)).

:- end_tests(evaluacion).

:- begin_tests(exportacion, [setup(politica_ejemplo)]).

test(resultado_rechazado_a_dict) :-
    ejemplo(3, _, Cursos),
    resultado_a_dict(resultado(3, Cursos, false, limite_area, ['FI1201']), D),
    D.id == 3,
    D.cumple == false,
    format(atom(Razon), "~w", [D.razon]),
    Razon == limite_area,
    length(D.selecciones, 4),
    length(D.cursos_a_quitar, 1).

test(resultado_que_cumple_tiene_razon_null) :-
    ejemplo(1, _, Cursos),
    resultado_a_dict(resultado(1, Cursos, true, ninguna, []), D),
    D.cumple == true,
    D.razon == null,
    D.cursos_a_quitar == [].

test(exportar_y_leer_de_vuelta) :-
    ejemplo(3, _, Cursos),
    tmp_file(resultados, Ruta),
    exportar_resultados(Ruta, [resultado(3, Cursos, false, limite_area, ['FI1201'])]),
    setup_call_cleanup(open(Ruta, read, S, [encoding(utf8)]),
                       json_read_dict(S, D),
                       close(S)),
    length(D.combinaciones, 1).

test(exportar_sin_resultados_es_json_valido) :-
    tmp_file(resultados, Ruta),
    exportar_resultados(Ruta, []),
    setup_call_cleanup(open(Ruta, read, S, [encoding(utf8)]),
                       json_read_dict(S, D),
                       close(S)),
    D.combinaciones == [].

:- end_tests(exportacion).
