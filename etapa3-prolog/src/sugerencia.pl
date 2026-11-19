:- module(sugerencia, [cursos_a_quitar/2]).

% Módulo: Curso a quitar (criterio adicional de grupos de 4)
% Responsable: Javier
% Rubro: Calcular qué curso se puede quitar de una combinación rechazada
%        para que cumpla todas las reglas (15, suma a 115 puntos)
%
% Para una combinación rechazada, busca los cursos que, quitados de uno en
% uno, dejan la combinación cumpliendo todas las reglas. REUTILIZA
% cumple/1 (razon.pl): no vuelve a escribir ninguna regla.
%
%   cursos_a_quitar(+Cursos, -Codigos)
%       Codigos son los códigos de los cursos C tales que quitar solo C de
%       Cursos deja una combinación que cumple, en el mismo orden en que
%       aparecen en Cursos. Es [] si la combinación ya cumple o si ningún
%       curso por sí solo la arregla. Es determinista.
%
% Idea: select/3 saca cada curso de la lista por backtracking, y findall/3
% junta los que sirven. La combinación que quedaría vacía no cuenta como
% solución (README, decisión 7).
%
% TODO (Javier):
%   - Caso límite a documentar: combinación que solo se arregla quitando
%     dos o más cursos (la lista queda vacía).

:- use_module(modelo).
:- use_module(razon).

% cursos_a_quitar(+Cursos, -Codigos)
%
% Primera cláusula: si la combinación ya cumple no hay nada que quitar.
% Se revisa antes que todo porque, si no, una combinación válida
% devolvería todos los cursos cuya salida la deja cumpliendo igual, y eso
% no es una sugerencia. El corte impide pasar a la segunda cláusula, y
% Codigos se unifica después del corte (como en razon.pl) para que una
% llamada con Codigos ya instanciado no caiga en la segunda cláusula.
cursos_a_quitar(Cursos, Codigos) :-
    cumple(Cursos),
    !,
    Codigos = [].
% Segunda cláusula: la combinación no cumple. select(Curso, Cursos, Resto)
% saca un curso a la vez por backtracking, en el orden de la lista, y deja
% en Resto los demás. Se descarta el Resto vacío (quitar el único curso no
% es solución) y se valida lo que queda con cumple/1. findall/3 recorre
% todas esas opciones y junta los códigos de los cursos que sirven; si
% ninguno sirve, da []. Al ser findall/3 hay una sola respuesta.
cursos_a_quitar(Cursos, Codigos) :-
    findall(Codigo,
            ( select(Curso, Cursos, Resto),
              Resto \== [],
              cumple(Resto),
              curso_codigo(Curso, Codigo) ),
            Codigos).
