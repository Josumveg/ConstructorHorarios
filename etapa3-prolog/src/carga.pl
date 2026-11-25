:- module(carga, [cargar_politica/1,
                  cargar_combinaciones/1,
                  json_a_curso/2,
                  json_a_combinacion/3]).

% Modulo: Carga de la politica y de las combinaciones
% Responsable: Jose
%
% La politica es un archivo de hechos y se consulta tal cual. Las
% combinaciones vienen en el JSON de Racket y quedan como hechos
% modelo:combinacion/2. Este es el unico modulo que usa assertz, porque
% solo carga datos de entrada.

:- use_module(library(http/json)).
:- use_module(modelo).

% cargar_politica(+Ruta)
cargar_politica(Ruta) :-
    exists_file(Ruta),
    !,
    consult(user:Ruta).
cargar_politica(Ruta) :-
    throw(error(existence_error(source_sink, Ruta), _)).

% cargar_combinaciones(+Ruta)
% Convierte todo el archivo antes de guardar, para no dejar la carga a medias
% si una combinacion viene mal.
cargar_combinaciones(Ruta) :-
    leer_json(Ruta, Json),
    campo(Json, combinaciones, Diccionarios),
    json_a_combinaciones(Diccionarios, 1, Combinaciones),
    retractall(modelo:combinacion(_, _)),
    guardar_combinaciones(Combinaciones).

leer_json(Ruta, Json) :-
    setup_call_cleanup(
        open(Ruta, read, Flujo, [encoding(utf8)]),
        json_read_dict(Flujo, Json),
        close(Flujo)).

json_a_combinaciones([], _, []).
json_a_combinaciones([Diccionario|Resto], Id, [Combinacion|Combinaciones]) :-
    json_a_combinacion(Diccionario, Id, Combinacion),
    SiguienteId is Id + 1,
    json_a_combinaciones(Resto, SiguienteId, Combinaciones).

guardar_combinaciones([]).
guardar_combinaciones([Combinacion|Resto]) :-
    assertz(modelo:Combinacion),
    guardar_combinaciones(Resto).

% json_a_combinacion(+Diccionario, +Id, -Combinacion)
json_a_combinacion(Diccionario, Id, combinacion(Id, Cursos)) :-
    campo(Diccionario, selecciones, Selecciones),
    maplist(json_a_curso, Selecciones, Cursos).

% json_a_curso(+Diccionario, -Curso)
json_a_curso(Diccionario, curso(Codigo, Grupo, Creditos, Carreras, Area)) :-
    campo(Diccionario, curso, TextoCodigo),
    campo(Diccionario, grupo, Grupo),
    campo(Diccionario, creditos, Creditos),
    campo(Diccionario, carreras, TextoCarreras),
    campo(Diccionario, area, TextoArea),
    atom_string(Codigo, TextoCodigo),
    maplist(atom_string, Carreras, TextoCarreras),
    atom_string(Area, TextoArea).

% Campo obligatorio: si falta, el error dice cual es.
campo(Diccionario, Clave, Valor) :-
    (   get_dict(Clave, Diccionario, Encontrado)
    ->  Valor = Encontrado
    ;   throw(error(existence_error(campo, Clave), _))
    ).
