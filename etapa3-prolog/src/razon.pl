:- module(razon, [primera_violacion/2,
                  primera_violacion/3,
                  cumple/1,
                  evaluar/2]).

% Modulo: Razon de rechazo
% Responsable: Javier
% Rubro: Razon de rechazo: corte, negacion por falla, orden de clausulas (14)
%
% Dice si una combinacion cumple las reglas y, si no, cual es la PRIMERA
% regla que viola. "Primera" segun el orden de orden_reglas/1 (hecho de
% data/politica.pl): el orden es parte del diseno y cambiarlo puede cambiar
% la razon reportada (README, 2.2.1).
%
%   primera_violacion(+Orden, +Cursos, -Regla)
%       Recorre la lista Orden y se queda con la primera regla R tal que
%       viola(R, Cursos) (reglas.pl). Aqui va el CORTE: una vez encontrada
%       la primera regla violada no se buscan mas. Recibe el orden como
%       argumento para poder probar ordenes distintos sin cambiar la
%       politica.
%   primera_violacion(+Cursos, -Regla)
%       Lo mismo con el orden de orden_reglas/1.
%   cumple(+Cursos)
%       Exito si no se viola ninguna regla. Va con NEGACION POR FALLA:
%       \+ primera_violacion(Cursos, _).
%   evaluar(+Cursos, -Veredicto)
%       Veredicto es cumple, o viola(Regla) con la primera regla violada.
%
% cumple/1 es el predicado de validacion que reutiliza sugerencia.pl
% (criterio de grupos de 4): no se duplica la logica de las reglas.
%
% TODO (Javier):
%   - Justificar en el README por que corte y por que negacion por falla
%     (que pasaria sin el corte: la misma combinacion tendria varias
%     razones al hacer backtracking).
%   - Sin assert/retract.

:- use_module(modelo).
:- use_module(reglas).

% primera_violacion(+Orden, +Cursos, -Regla)
primera_violacion(_Orden, _Cursos, _Regla) :-
    pendiente(primera_violacion, 'Javier').

% primera_violacion(+Cursos, -Regla): con el orden de la politica.
primera_violacion(_Cursos, _Regla) :-
    pendiente(primera_violacion, 'Javier').

% cumple(+Cursos)
cumple(_Cursos) :-
    pendiente(cumple, 'Javier').

% evaluar(+Cursos, -Veredicto)
evaluar(_Cursos, _Veredicto) :-
    pendiente(evaluar, 'Javier').
