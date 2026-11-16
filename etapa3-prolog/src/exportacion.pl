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

% resultado_a_dict(+Resultado, -Dict)
resultado_a_dict(_Resultado, _Dict) :-
    pendiente(resultado_a_dict, 'Sebastian').

% exportar_resultados(+Ruta, +Resultados)
exportar_resultados(_Ruta, _Resultados) :-
    pendiente(exportar_resultados, 'Sebastian').
