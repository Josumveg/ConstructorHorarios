% Pruebas del modelo y la carga (Jose).
% Correr desde etapa3-prolog/: swipl -q -g run_tests -t halt tests/test_modelo_carga.pl

:- use_module(library(plunit)).
:- use_module('../src/modelo').
:- use_module('../src/carga').
:- use_module(ejemplos).

:- begin_tests(modelo).

test(accesores) :-
    ejemplo(1, _, Cursos),
    Cursos = [Curso|_],
    curso_codigo(Curso, 'CE1106'),
    curso_grupo(Curso, 1),
    curso_creditos(Curso, 3),
    curso_area(Curso, computacion),
    curso_carreras(Curso, [_]).

test(creditos_totales) :-
    ejemplo(3, _, Cursos),
    creditos_totales(Cursos, 10).

test(creditos_totales_vacia) :-
    creditos_totales([], 0).

:- end_tests(modelo).

:- begin_tests(carga).

test(cargar_politica) :-
    ruta_datos('politica.pl', Ruta),
    cargar_politica(Ruta),
    max_cursos_area(2),
    orden_reglas([balance_carreras|_]).

test(cargar_combinaciones_ids) :-
    ruta_datos('combinaciones.json', Ruta),
    cargar_combinaciones(Ruta),
    findall(Id, combinacion(Id, _), Ids),
    Ids == [1, 2, 3, 4, 5].

test(combinaciones_coinciden_con_ejemplos) :-
    ruta_datos('combinaciones.json', Ruta),
    cargar_combinaciones(Ruta),
    forall(ejemplo(Id, _, Cursos), combinacion(Id, Cursos)).

test(cargar_dos_veces_no_duplica) :-
    ruta_datos('combinaciones.json', Ruta),
    cargar_combinaciones(Ruta),
    cargar_combinaciones(Ruta),
    findall(Id, combinacion(Id, _), Ids),
    length(Ids, 5).

% El error debe venir de la carga, no del "pendiente" del esqueleto.
test(archivo_inexistente) :-
    catch(cargar_combinaciones('no_existe.json'), error(Formal, _), true),
    nonvar(Formal),
    Formal \= pendiente(_, _).

test(curso_sin_area) :-
    catch(json_a_curso(_{curso: "CE1106", grupo: 1, creditos: 3, carreras: []}, _),
          error(Formal, _), true),
    nonvar(Formal),
    Formal \= pendiente(_, _).

:- end_tests(carga).
