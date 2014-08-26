%%
% Cut area from LAS file using Shape file
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

clear all; clc; close all;
addpath('sdf_reader')

%% Settigns
settings;

[input_las, source_folder, FilterIndex] = uigetfile({'*.las'}, 'Choose the source LAS file...', 'MultiSelect', 'off');

% No file selected
if input_las == 0,
    disp('No selected file! Return!')
    return;
end;

[file_shp, shape_folder, FilterIndex] = uigetfile({'*.shp'}, 'Choose the Shape file for limits...', 'MultiSelect', 'off');

% No file selected
if file_shp == 0,
    disp('No selected file! Return!')   
    return;
end;

[output_las, result_folder, FilterIndex] = uiputfile({'*.las'}, 'Result...');

% No file selected
if output_las == 0,
    disp('No selected file! Return!')    
    return;
end;

%% Call lastools

dos_cmd = ['lasclip.exe -i "', source_folder, '\', input_las '" -o "', result_folder, '\', output_las '" ' ...
        '-poly "', shape_folder, '\', file_shp '" -verbose'];   
dos_cmd

dos(dos_cmd);