:- module(sugerencia, [cursos_a_quitar/2]).

% Modulo: Curso a quitar (criterio adicional de grupos de 4)
% Responsable: Javier
% Rubro: Calcular que curso se puede quitar de una combinacion rechazada
%        para que cumpla todas las reglas (15, suma a 115 puntos)
%
% Para una combinacion rechazada, busca los cursos que, quitados de uno en
% uno, dejan la combinacion cumpliendo todas las reglas. REUTILIZA
% cumple/1 (razon.pl): no vuelve a escribir ninguna regla.
%
%   cursos_a_quitar(+Cursos, -Codigos)
%       Codigos son los codigos de los cursos C tales que quitar solo C de
%       Cursos deja una combinacion que cumple. Es [] si la combinacion ya
%       cumple o si ningun curso por si solo la arregla.
%
% Idea: select/3 saca cada curso de la lista por backtracking, y findall/3
% junta los que sirven. La combinacion que quedaria vacia no cuenta como
% solucion (README, decision 9).
%
% TODO (Javier):
%   - cursos_a_quitar con select/3 + cumple/1 + findall/3.
%   - Caso limite a documentar: combinacion que solo se arregla quitando
%     dos o mas cursos (la lista queda vacia).
%   - Sin assert/retract.

:- use_module(modelo).
:- use_module(razon).

% cursos_a_quitar(+Cursos, -Codigos)
cursos_a_quitar(_Cursos, _Codigos) :-
    pendiente(cursos_a_quitar, 'Javier').
