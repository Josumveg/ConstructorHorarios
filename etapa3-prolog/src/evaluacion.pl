:- module(evaluacion, [evaluar_combinacion/2,
                       evaluar_todas/1]).

% Modulo: Recorrido de todas las combinaciones
% Responsable: Sebastian
% Rubro: Exportacion del resultado (10) + requerimiento funcional 6
%        (recorrer todas las combinaciones por backtracking)
%
% Une la carga con las reglas: para cada hecho combinacion/2 arma un
% resultado/5 (modelo.pl) con el veredicto, la razon y los cursos a quitar.
%
%   evaluar_combinacion(+Combinacion, -Resultado)
%       Una combinacion(Id, Cursos) -> resultado(Id, Cursos, Cumple, Razon,
%       CursosAQuitar), usando evaluar/2 (razon.pl) y cursos_a_quitar/2
%       (sugerencia.pl). Si cumple: Cumple = true, Razon = ninguna y
%       CursosAQuitar = [].
%   evaluar_todas(-Resultados)
%       Recorre por backtracking todos los hechos combinacion/2 y junta un
%       resultado por cada uno, en el orden del archivo (findall/3).
%
% TODO (Sebastian):
%   - evaluar_combinacion y evaluar_todas.
%   - No generar ni filtrar combinaciones: solo evaluar las que se
%     cargaron.
%   - Sin assert/retract: el estado viaja en los argumentos.

:- use_module(modelo).
:- use_module(razon).
:- use_module(sugerencia).

% evaluar_combinacion(+Combinacion, -Resultado)

% Evalua una combinacion y conserva sus cursos originales.
evaluar_combinacion(combinacion(Id, Cursos),
                    resultado(Id, Cursos, Cumple, Razon, CursosAQuitar)) :-
    evaluar(Cursos, Veredicto),
    (   Veredicto = cumple
    ->  Cumple = true,
        Razon = ninguna,
        CursosAQuitar = []
    ;   Veredicto = viola(Razon),
        Cumple = false,
        cursos_a_quitar(Cursos, CursosAQuitar)
    ).

% Recorre por backtracking las combinaciones cargadas.
evaluar_todas(Resultados) :-
    findall(Resultado,
            ( combinacion(Id, Cursos),
              evaluar_combinacion(combinacion(Id, Cursos), Resultado)
            ),
            Resultados).