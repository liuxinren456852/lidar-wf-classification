%%
% Cut area from LAS file using Shape file
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

clear all; clc;
addpath('sdf_reader')

%% Settigns
settings;

% result_folder = 'C:\Zoli\Incidence\datasets';
% source_folder = 'E:\zoli-cuts';
% shape_folder = 'C:\Zoli\Incidence\datasets';
% 
% dataset_name = 'dataset_7';
% filepat = 'Q680i-1';
% 
% file_shp = 'dataset_7_Corbin_12_with_extrabytes_UTM18_Amplitude - Q680i - 130617_192721_1 - originalpoints_aoi.shp'
% input_las = 'Q680i-1.las'
% output_las = [dataset_name '_' 'Corbin_12_with_extrabytes_UTM18_Amplitude - Q680i - 130617_192721_1.las']

[input_las, source_folder, FilterIndex] = uigetfile({'*.las'}, 'Choose the source LAS file...', 'MultiSelect', 'off');
[file_shp, shape_folder, FilterIndex] = uigetfile({'*.shp'}, 'Choose the Shape file for limits...', 'MultiSelect', 'off');
[output_las, result_folder, FilterIndex] = uiputfile({'*.las'}, 'Result...');



%% Working

dos_cmd = ['lasclip.exe -i "', source_folder, '\', input_las '" -o "', result_folder, '\', output_las '" ' ...
        '-poly "', shape_folder, '\', file_shp '" -verbose'];   
dos_cmd

dos(dos_cmd);