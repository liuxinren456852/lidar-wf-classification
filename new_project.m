%%
% Create new project
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
clear all; clc; close all;

project_name = input('Project name: ', 's');    

if isempty(project_name),
    disp('No project name specified! Return!')
    return;
end;

dname = uigetdir('C:\');

% No dir selected
if dname == 0,
    disp('No selected directory! Return!')
    return;
end;

project.name = project_name;
project.result_folder = dname;
project.datasets = [];

save(['projects/project_' project_name '.mat'], 'project');