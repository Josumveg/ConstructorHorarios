:- module(reglas, [viola/2,
                   viola_balance/1,
                   viola_area/1,
                   viola_incompatibilidad/1,
                   creditos_carrera/3,
                   incompatibles/2]).

% Modulo: Reglas de politica
% Responsable: Pablo
% Rubro: Reglas de politica correctas (24) + Predicado usable en mas de un
%        modo (6)
%
% Las tres reglas son predicados parametrizados por los hechos de politica
% (data/politica.pl): ninguna tiene un numero ni un par escrito en el
% codigo. Cada una recibe la lista de cursos de una combinacion y TIENEN
% EXITO cuando la combinacion la VIOLA.
%
%   Regla 1, balance_carreras:
%     Los creditos de una carrera son los de sus cursos; un curso
%     compartido reparte sus creditos en partes iguales entre sus carreras
%     (README, decision 4). La regla se viola si algun
%     creditos_carrera * 100 > max_porcentaje_carrera * creditos_totales.
%     Se compara sin dividir (y con rdiv para el reparto) para evitar
%     errores de redondeo con floats. Una combinacion de una sola carrera
%     es valida mientras no pase su maximo.
%
%   Regla 2, limite_area:
%     Se viola si alguna area tiene mas de max_cursos_area(N) cursos.
%
%   Regla 3, incompatibilidad:
%     Se viola si la combinacion tiene los dos cursos de un par declarado
%     con par_incompatible/2. La relacion es simetrica (incompatibles/2).
%
% Predicado usable en mas de un modo (requerimiento funcional 5):
%   incompatibles/2 y creditos_carrera/3. Ejemplos de consulta de cada
%   modo en el README, seccion 2.3.
%
% Politica: max_porcentaje_carrera/2, max_cursos_area/1 y
% par_incompatible/2 estan definidos en el modulo user (data/politica.pl).
%
% TODO (Pablo):
%   - creditos_carrera(+Cursos, ?Carrera, ?Creditos): con Carrera
%     instanciada calcula sus creditos; sin instanciar enumera por
%     backtracking cada carrera de la combinacion con los suyos. Los
%     creditos pueden ser racionales (rdiv).
%   - viola_balance, viola_area, viola_incompatibilidad.
%   - incompatibles(?A, ?B): simetrica. Debe servir para verificar un par,
%     para encontrar los incompatibles de un curso (A o B instanciado) y
%     para enumerar todos los pares.
%   - Sin assert/retract y sin variables globales.

:- use_module(modelo).

% viola(?Regla, +Cursos): la combinacion viola la regla. Con Regla sin
% instanciar enumera todas las reglas violadas.
viola(balance_carreras, Cursos) :- viola_balance(Cursos).
viola(limite_area, Cursos) :- viola_area(Cursos).
viola(incompatibilidad, Cursos) :- viola_incompatibilidad(Cursos).

% Alguna carrera pasa su porcentaje maximo.
viola_balance(Cursos) :-
    creditos_totales(Cursos, Total),
    max_porcentaje_carrera(Carrera, Maximo),
    creditos_carrera(Cursos, Carrera, CreditosCarrera),
    CreditosCarrera * 100 > Maximo * Total.



% contar_area(+Cursos, +Area, -Cantidad)

contar_area([], _, 0).

contar_area([Cabeza|Resto], Area, Cantidad) :-
    curso_area(Cabeza, Area),
    contar_area(Resto, Area, Subtotal),
    Cantidad is Subtotal + 1.

contar_area([Cabeza|Resto], Area, Cantidad) :-
    curso_area(Cabeza, AreaCurso),
    AreaCurso \= Area,
    contar_area(Resto, Area, Cantidad).

viola_area(Cursos) :-
    Cursos = [Cabeza|_],
    curso_area(Cabeza, Area),
    max_cursos_area(N),
    contar_area(Cursos, Area, Cantidad),
    Cantidad > N.

viola_area([_|Resto]) :-
    viola_area(Resto).

% La combinacion trae los dos cursos de un par incompatible.
viola_incompatibilidad(Cursos) :-
    Cursos=[Cabeza|Resto],
    member(OtroCurso, Resto),
    curso_codigo(Cabeza, Codigo1),
    curso_codigo(OtroCurso, Codigo2),
    incompatibles(Codigo1, Codigo2).

viola_incompatibilidad([_|Resto]) :-
    viola_incompatibilidad(Resto).

% creditos_carrera(+Cursos, ?Carrera, ?Creditos)
creditos_carrera([], _, 0).

creditos_carrera(Cursos, Carrera, Creditos) :-
    Cursos=[Cabeza|Resto],
    curso_carreras(Cabeza, Carreras),
    length(Carreras, CantidadCarreras),
    curso_creditos(Cabeza, Creditos1),
    member(Carrera, Carreras),
    Aporte is Creditos1 rdiv CantidadCarreras,
    creditos_carrera(Resto, Carrera, Subtotal),
    Creditos is Subtotal + Aporte.

creditos_carrera(Cursos, Carrera, Creditos) :-
    Cursos=[Cabeza|Resto],
    curso_carreras(Cabeza, Carreras),
    \+ member(Carrera, Carreras),
    creditos_carrera(Resto, Carrera, Subtotal),
    Creditos is Subtotal.

creditos_carrera(Cursos, Carrera, Creditos) :-
    var(Carrera),
    member(Curso, Cursos),
    curso_carreras(Curso, Carreras),
    member(Carrera, Carreras),
    creditos_carrera(Cursos, Carrera, Creditos).
    

% incompatibles(?A, ?B)
incompatibles(A, B) :-
    par_incompatible(X,Y),
    X=A, 
    Y=B.
incompatibles(A, B) :-
    par_incompatible(X,Y),
    X=B, 
    Y=A. 

    
