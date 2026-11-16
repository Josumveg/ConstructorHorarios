% Punto de entrada de la etapa 3. Integracion de los modulos:
%
%   cargar politica y combinaciones   (Jose)
%     -> evaluar cada combinacion contra las reglas
%          reglas.pl (Pablo), razon.pl y sugerencia.pl (Javier)
%     -> recorrer todas y exportar    (Sebastian)
%
% Tarea compartida por todo el equipo (ver distribucion-tareas-etapa3-
% cemestre.md, seccion 5): se completa en conjunto cuando cada modulo este
% probado por separado. El flujo ya esta conectado; mientras los modulos
% tengan TODO, el programa termina con un error que dice cual falta.
%
% Uso:
%   swipl main.pl [combinaciones] [politica] [salida]
% Sin argumentos usa las rutas por defecto de abajo.

:- use_module(library(main)).
:- use_module(src/modelo).
:- use_module(src/carga).
:- use_module(src/evaluacion).
:- use_module(src/exportacion).

:- initialization(main, main).

ruta_combinaciones_defecto('data/combinaciones.json').
ruta_politica_defecto('data/politica.pl').
ruta_salida_defecto('data/resultados.json').

% Corre el pipeline completo.
ejecutar(RutaCombinaciones, RutaPolitica, RutaSalida) :-
    cargar_politica(RutaPolitica),
    cargar_combinaciones(RutaCombinaciones),
    evaluar_todas(Resultados),
    exportar_resultados(RutaSalida, Resultados).

% El argumento en la posicion I, o el defecto si no se paso.
argumento(Argv, I, _, Ruta) :-
    nth0(I, Argv, Ruta),
    !.
argumento(_, _, Defecto, Defecto).

main(Argv) :-
    ruta_combinaciones_defecto(DefComb),
    ruta_politica_defecto(DefPol),
    ruta_salida_defecto(DefSal),
    argumento(Argv, 0, DefComb, RutaCombinaciones),
    argumento(Argv, 1, DefPol, RutaPolitica),
    argumento(Argv, 2, DefSal, RutaSalida),
    catch(ejecutar(RutaCombinaciones, RutaPolitica, RutaSalida),
          Error,
          informar(Error)),
    format("Resultados exportados a ~w~n", [RutaSalida]).

% Muestra el error sin traza larga y termina con codigo 1.
informar(error(pendiente(Nombre, Responsable), _)) :-
    !,
    format(user_error, "Error: falta implementar ~w (~w)~n", [Nombre, Responsable]),
    halt(1).
informar(Error) :-
    print_message(error, Error),
    halt(1).
