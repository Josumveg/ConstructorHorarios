:- encoding(utf8).

% Archivo de politica de la etapa 3: los parametros de las reglas como
% hechos. Los valores se pueden cambiar en la defensa sin tocar el codigo.
% Se carga con cargar_politica/1 (carga.pl).

% Regla 1: porcentaje maximo de los creditos totales de una combinacion
% que puede aportar cada carrera.
max_porcentaje_carrera('Ingeniería en Computadores', 70).
max_porcentaje_carrera('Ingeniería en Producción Industrial', 70).

% Regla 2: maximo de cursos de una misma area en una combinacion.
max_cursos_area(2).

% Regla 3: pares de cursos incompatibles. Se declara un solo sentido; la
% relacion simetrica la resuelve incompatibles/2 (reglas.pl).
%   PI2609 / PI2610: Probabilidad y Estadistica del plan de Computadores y
%                    de Produccion Industrial (mismo contenido).
%   CI1407 / CI1106: Comunicacion de cada plan (se traslapan).
%   SE1400 / SE1100: la actividad cultural-deportiva sustituye a la cultural.
%   PI5516 / PI3501: Ingenieria Economica y Costos Industriales I (analisis
%                    de costos en ambos).
par_incompatible('PI2609', 'PI2610').
par_incompatible('CI1407', 'CI1106').
par_incompatible('SE1400', 'SE1100').
par_incompatible('PI5516', 'PI3501').

% Orden en que se revisan las reglas. La razon de rechazo es la primera
% regla de esta lista que la combinacion viola, asi que cambiar el orden
% puede cambiar la razon reportada.
orden_reglas([balance_carreras, limite_area, incompatibilidad]).
