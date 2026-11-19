:- module(razon, [primera_violacion/2,
                  primera_violacion/3,
                  cumple/1,
                  evaluar/2]).

% Módulo: Razón de rechazo
% Responsable: Javier
% Rubro: Razón de rechazo: corte, negación por falla, orden de cláusulas (14)
%
% Dice si una combinación cumple las reglas y, si no, cuál es la PRIMERA
% regla que viola. "Primera" según el orden de orden_reglas/1 (hecho de
% data/politica.pl): el orden es parte del diseño y cambiarlo puede cambiar
% la razón reportada (README, 2.2.1).
%
%   primera_violacion(+Orden, +Cursos, -Regla)
%       Recorre la lista Orden y se queda con la primera regla R tal que
%       viola(R, Cursos) (reglas.pl). Aquí va el CORTE: una vez encontrada
%       la primera regla violada no se buscan más ni se repite la misma
%       (viola/2 puede tener éxito varias veces para una regla). Es
%       determinista y steadfast: la salida se unifica DESPUÉS del corte.
%       Recibe el orden como argumento para poder probar órdenes distintos
%       sin cambiar la política.
%   primera_violacion(+Cursos, -Regla)
%       Lo mismo con el orden de orden_reglas/1.
%   cumple(+Cursos)
%       Éxito si no se viola ninguna regla. Va con NEGACIÓN POR FALLA:
%       \+ primera_violacion(Cursos, _).
%   evaluar(+Cursos, -Veredicto)
%       Veredicto es cumple, o viola(Regla) con la primera regla violada.
%       Determinista: el corte elige una sola de sus dos cláusulas.
%
% cumple/1 es el predicado de validación que reutiliza sugerencia.pl
% (criterio de grupos de 4): no se duplica la lógica de las reglas.
%
% TODO (Javier):
%   - Justificar en el README por qué corte y por qué negación por falla
%     (qué pasaría sin el corte: la misma combinación tendría varias
%     razones al hacer backtracking).

:- use_module(modelo).
:- use_module(reglas).

% primera_violacion(+Orden, +Cursos, -Regla)
% Caso base implícito: con la lista vacía ninguna cláusula aplica y falla.
%
% La cabeza de Orden se viola: el corte descarta la segunda cláusula (no se
% revisan las reglas siguientes) y las demás formas en que viola/2 podría
% volver a tener éxito con la misma regla. Regla se unifica después del
% corte para que una llamada con Regla instanciada no salte a reglas
% posteriores: solo tiene éxito si esa es de verdad la primera violación.
primera_violacion([R0|_], Cursos, Regla) :-
    viola(R0, Cursos),
    !,
    Regla = R0.
% La cabeza no se viola: se sigue con el resto del orden.
primera_violacion([_|Resto], Cursos, Regla) :-
    primera_violacion(Resto, Cursos, Regla).

% primera_violacion(+Cursos, -Regla): con el orden de la política.
primera_violacion(Cursos, Regla) :-
    orden_reglas(Orden),
    primera_violacion(Orden, Cursos, Regla).

% cumple(+Cursos)
% Negación por falla: la combinación cumple si NO se puede demostrar que
% viola alguna regla.
cumple(Cursos) :-
    \+ primera_violacion(Cursos, _).

% evaluar(+Cursos, -Veredicto)
% Si hay una regla violada, el corte impide caer en la segunda cláusula
% (no se puede reportar viola(R) y también cumple). Como en
% primera_violacion/3, el veredicto se unifica después del corte.
evaluar(Cursos, Veredicto) :-
    primera_violacion(Cursos, Regla),
    !,
    Veredicto = viola(Regla).
evaluar(_Cursos, cumple).
