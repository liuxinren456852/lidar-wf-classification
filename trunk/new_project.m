%%
% Create new project
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
clear all; clc;

project_name = input('Project name: ', 's');
dname = uigetdir('C:\');

project.name = project_name;
project.result_folder = dname;
project.datasets = [];

save(['project_' project_name '.mat'], 'project');