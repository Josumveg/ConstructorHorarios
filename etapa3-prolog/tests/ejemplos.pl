:- module(ejemplos, [carrera/2,
                     ejemplo/3,
                     esperado/4,
                     ruta_datos/2,
                     politica_ejemplo/0]).

% Datos de prueba compartidos por todas las suites de tests/.
%
% Son las 5 combinaciones de data/combinaciones.json con la politica de
% data/politica.pl (CE max 70%, PI max 70%, maximo 2 cursos por area, 4 pares
% incompatibles, orden balance_carreras, limite_area, incompatibilidad). El
% resultado esperado se puede calcular a mano. Un curso compartido reparte
% sus creditos en partes iguales entre sus carreras.
%
%   1 a_cumple            CE1106 (CE, 3) + MI2101 (PI, 3)
%                         CE 50%, PI 50%: cumple.
%   2 b_balance           MI2101 + QU1107 + CI1106, los tres solo PI
%                         PI 100% > 70%: balance_carreras. Quitar un curso
%                         no ayuda (sigue siendo solo PI).
%   3 c_area              CE1106 (CE, 3) + QU1106, FI1101 (compartidos, 3)
%                         + FI1201 (compartido, 1)
%                         CE 65%, PI 35%: balance bien. 3 cursos de
%                         fisica_quimica > 2: limite_area. Quitar FI1201
%                         lo arregla; quitar QU1106 o FI1101 deja CE en
%                         71.4% (balance); quitar CE1106 deja 3 de
%                         fisica_quimica.
%   4 d_incompatibilidad  CI1407 (CE, 2) + CI1106 (PI, 2) + MA1102 (comp., 4)
%                         balance y area bien, pero CI1407 y CI1106 son un
%                         par incompatible. Quitar cualquiera de los dos
%                         lo arregla; quitar MA1102 no.
%   5 e_orden             QU1107 + FI2103 + QU1104, los tres solo PI y de
%                         fisica_quimica: viola balance_carreras Y
%                         limite_area. La razon depende del orden.
%
% Los acentos van escapados (í, ó) para no depender del encoding
% de este archivo.

carrera(ce, 'Ingeniería en Computadores').
carrera(pi, 'Ingeniería en Producción Industrial').

% curso_ej(+Codigo, +Grupo, +Creditos, +ClavesCarrera, +Area, -Curso)
curso_ej(Codigo, Grupo, Creditos, Claves, Area,
         curso(Codigo, Grupo, Creditos, Carreras, Area)) :-
    maplist(carrera, Claves, Carreras).

% ejemplo(?Id, ?Nombre, ?Cursos): coincide con data/combinaciones.json
ejemplo(1, a_cumple, [C1, C2]) :-
    curso_ej('CE1106', 1, 3, [ce], computacion, C1),
    curso_ej('MI2101', 1, 3, [pi], industrial, C2).
ejemplo(2, b_balance, [C1, C2, C3]) :-
    curso_ej('MI2101', 1, 3, [pi], industrial, C1),
    curso_ej('QU1107', 2, 3, [pi], fisica_quimica, C2),
    curso_ej('CI1106', 1, 2, [pi], humanidades, C3).
ejemplo(3, c_area, [C1, C2, C3, C4]) :-
    curso_ej('CE1106', 2, 3, [ce], computacion, C1),
    curso_ej('QU1106', 1, 3, [ce, pi], fisica_quimica, C2),
    curso_ej('FI1101', 1, 3, [ce, pi], fisica_quimica, C3),
    curso_ej('FI1201', 1, 1, [ce, pi], fisica_quimica, C4).
ejemplo(4, d_incompatibilidad, [C1, C2, C3]) :-
    curso_ej('CI1407', 1, 2, [ce], humanidades, C1),
    curso_ej('CI1106', 2, 2, [pi], humanidades, C2),
    curso_ej('MA1102', 1, 4, [ce, pi], matematica, C3).
ejemplo(5, e_orden, [C1, C2, C3]) :-
    curso_ej('QU1107', 1, 3, [pi], fisica_quimica, C1),
    curso_ej('FI2103', 1, 3, [pi], fisica_quimica, C2),
    curso_ej('QU1104', 1, 1, [pi], fisica_quimica, C3).

% esperado(?Nombre, ?Cumple, ?Razon, ?CursosAQuitar) con el orden de la politica
esperado(a_cumple, true, ninguna, []).
esperado(b_balance, false, balance_carreras, []).
esperado(c_area, false, limite_area, ['FI1201']).
esperado(d_incompatibilidad, false, incompatibilidad, ['CI1407', 'CI1106']).
esperado(e_orden, false, balance_carreras, []).

% ruta_datos(+Archivo, -Ruta): ruta absoluta de un archivo de data/, sin
% depender de la carpeta desde donde se corran las pruebas.
ruta_datos(Archivo, Ruta) :-
    module_property(ejemplos, file(Fuente)),
    file_directory_name(Fuente, DirTests),
    file_directory_name(DirTests, Raiz),
    atomic_list_concat([Raiz, '/data/', Archivo], Ruta).

% Carga data/politica.pl en user, sin pasar por carga.pl (asi las pruebas
% de las reglas no dependen de que la carga este lista).
politica_ejemplo :-
    ruta_datos('politica.pl', Ruta),
    consult(user:Ruta).
