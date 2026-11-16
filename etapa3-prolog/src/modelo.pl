:- module(modelo, [combinacion/2,
                   curso_codigo/2,
                   curso_grupo/2,
                   curso_creditos/2,
                   curso_carreras/2,
                   curso_area/2,
                   creditos_totales/2,
                   pendiente/2]).

% Modulo: Modelo de datos compartido
% Responsable: Jose
% Rubro: Modelado de datos (hechos, terminos compuestos, listas) y carga (10)
%
% Equivalente a tipos.rkt de la etapa 2: es el contrato de terminos contra
% el que trabajan los demas modulos. Acordarlo en conjunto antes de
% programar.
%
% Terminos compuestos:
%
%   curso(Codigo, Grupo, Creditos, Carreras, Area)
%       Codigo   : atomo, ej. 'CE1106'
%       Grupo    : entero, numero de grupo elegido
%       Creditos : entero (hay cursos de 0 creditos)
%       Carreras : lista de atomos; una carrera, o las dos si el curso es
%                  compartido
%       Area     : atomo, ej. computacion (ver README, decision 2)
%
%   combinacion(Id, Cursos)
%       Id     : entero, posicion de la combinacion en el archivo de Racket
%       Cursos : lista de curso/5
%
%   resultado(Id, Cursos, Cumple, Razon, CursosAQuitar)
%       Cumple        : true o false
%       Razon         : ninguna, o el nombre de la primera regla violada
%                       (balance_carreras, limite_area, incompatibilidad)
%       CursosAQuitar : lista de codigos; los cursos que, quitados de uno en
%                       uno, dejan la combinacion cumpliendo todas las
%                       reglas (vacia si cumple o si ninguno lo logra)
%
% Las combinaciones son hechos combinacion/2. Se cargan con assertz solo al
% leer el archivo de entrada (carga.pl); el enunciado no permite
% assert/retract para nada mas.
%
% Los hechos de politica (max_porcentaje_carrera/2, max_cursos_area/1,
% par_incompatible/2, orden_reglas/1) viven en data/politica.pl y se cargan
% en el modulo user.

:- dynamic combinacion/2.

curso_codigo(curso(Codigo, _, _, _, _), Codigo).
curso_grupo(curso(_, Grupo, _, _, _), Grupo).
curso_creditos(curso(_, _, Creditos, _, _), Creditos).
curso_carreras(curso(_, _, _, Carreras, _), Carreras).
curso_area(curso(_, _, _, _, Area), Area).

% Suma de los creditos de una lista de cursos.
creditos_totales([], 0).
creditos_totales([curso(_, _, Creditos, _, _)|Resto], Total) :-
    creditos_totales(Resto, Parcial),
    Total is Parcial + Creditos.

% Marca de lo que falta por programar: main.pl lo muestra como error claro.
pendiente(Nombre, Responsable) :-
    throw(error(pendiente(Nombre, Responsable), _)).
