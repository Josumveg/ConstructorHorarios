:- module(carga, [cargar_politica/1,
                  cargar_combinaciones/1,
                  json_a_curso/2,
                  json_a_combinacion/3]).

% Modulo: Carga de la politica y de las combinaciones
% Responsable: Jose
% Rubro: Modelado de datos (hechos, terminos compuestos, listas) y carga (10)
%
% Lee los dos archivos de entrada y los deja como hechos:
%   - la politica (data/politica.pl) es un archivo de hechos, asi que
%     basta consultarlo en el modulo user;
%   - las combinaciones (JSON de Racket, esquema en data/data_doc.md) se
%     leen con library(http/json) y se guardan como hechos
%     modelo:combinacion/2.
%
% Es el unico modulo que ve JSON crudo: el resto solo ve los terminos de
% modelo.pl. Del JSON solo se usan, por seleccion, curso, grupo, creditos,
% carreras y area; el resto (bloques, creditos_totales) se ignora.
%
% TODO (Jose):
%   - cargar_politica: consult(user:Ruta). Error claro si no existe.
%   - cargar_combinaciones: abrir el archivo con encoding(utf8), leer con
%     json_read_dict, borrar las combinaciones previas (retractall) y
%     guardar una combinacion(Id, Cursos) por elemento del arreglo
%     "combinaciones", con Id = posicion (desde 1). El assertz es el unico
%     permitido, porque es carga de datos de entrada.
%   - json_a_curso: dict de una seleccion -> curso/5. Los strings del JSON
%     pasan a atomos (atom_string/2), tambien cada carrera.
%   - json_a_combinacion: dict + Id -> combinacion/2.
%   - Errores claros: archivo inexistente, JSON mal formado, falta un campo
%     obligatorio (sobre todo area).

:- use_module(library(http/json)).
:- use_module(modelo).

% cargar_politica(+Ruta)
cargar_politica(_Ruta) :-
    pendiente(cargar_politica, 'Jose').

% cargar_combinaciones(+Ruta)
cargar_combinaciones(_Ruta) :-
    pendiente(cargar_combinaciones, 'Jose').

% json_a_curso(+Dict, -Curso)
json_a_curso(_Dict, _Curso) :-
    pendiente(json_a_curso, 'Jose').

% json_a_combinacion(+Dict, +Id, -Combinacion)
json_a_combinacion(_Dict, _Id, _Combinacion) :-
    pendiente(json_a_combinacion, 'Jose').
