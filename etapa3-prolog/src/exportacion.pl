:- module(exportacion, [resultado_a_dict/2,
                        exportar_resultados/2]).

% Modulo: Exportacion de resultados
% Responsable: Sebastian
% Rubro: Exportacion del resultado (veredicto + razon + justificacion del
%        formato) (10)
%
% Escribe un JSON con un objeto por combinacion (esquema en
% data/data_doc.md). Es el contrato con la etapa 4 (Java), que lee
% exactamente este archivo.
%
%   resultado_a_dict(+Resultado, -Dict)
%       resultado/5 -> dict listo para json_write_dict/3:
%         _{ id: Id,
%            selecciones: [_{curso: "CE1106", grupo: 1}, ...],
%            cumple: true/false,
%            razon: null o "balance_carreras" / "limite_area" /
%                   "incompatibilidad",
%            cursos_a_quitar: ["FI1201", ...] }
%   exportar_resultados(+Ruta, +Resultados)
%       Escribe {"combinaciones": [...]} en Ruta, en UTF-8.
%
% Campos del enunciado: selecciones (pares curso-grupo), cumple y razon.
% Campos agregados (justificar en el README, 2.2.3): id, para que Java
% cruce cada resultado con la combinacion de Racket que tiene bloques y
% creditos, y cursos_a_quitar (criterio de grupos de 4).
%
% TODO (Sebastian):
%   - resultado_a_dict: codigos como strings; razon ninguna -> null.
%   - exportar_resultados: json_write_dict con la opcion width(0) o con
%     sangria legible; verificar que se pueda leer de vuelta con
%     json_read_dict.
%   - Si no hay combinaciones, el archivo sigue siendo JSON valido
%     ({"combinaciones": []}).
%   - Justificar el formato JSON en el README (2.2.3), ligado a una
%     decision real.

:- use_module(library(http/json)).
:- use_module(modelo).
:- use_module(library(apply)).

% Convierte el resultado al formato acordado con Java.
resultado_a_dict(resultado(Id, Cursos, Cumple, Razon, CursosAQuitar),
                 Dict) :-
    maplist(curso_a_dict, Cursos, Selecciones),
    razon_a_json(Razon, RazonJSON),
    maplist(atom_string, CursosAQuitar, CodigosJSON),
    Dict = _{
        id: Id,
        selecciones: Selecciones,
        cumple: Cumple,
        razon: RazonJSON,
        cursos_a_quitar: CodigosJSON
    }.

% Conserva el codigo y el grupo de cada seleccion.
curso_a_dict(Curso, Dict) :-
    curso_codigo(Curso, Codigo),
    curso_grupo(Curso, Grupo),
    atom_string(Codigo, CodigoJSON),
    Dict = _{curso: CodigoJSON, grupo: Grupo}.

% Una combinacion aceptada no tiene razon de rechazo.
razon_a_json(ninguna, null).
razon_a_json(balance_carreras, "balance_carreras").
razon_a_json(limite_area, "limite_area").
razon_a_json(incompatibilidad, "incompatibilidad").

% Escribe el documento completo y cierra el archivo.
exportar_resultados(Ruta, Resultados) :-
    maplist(resultado_a_dict, Resultados, Diccionarios),
    Documento = _{combinaciones: Diccionarios},
    setup_call_cleanup(
        open(Ruta, write, Salida, [encoding(utf8)]),
        ( json_write_dict(Salida, Documento, [width(80), step(2)]),
          nl(Salida)
        ),
        close(Salida)
    ).