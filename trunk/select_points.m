%%
% Selector: Select points and save them to another file
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

clear all; clf; close all;

%% Settings
settings;

load(project_file)

save_name_def = 'nan';

dataset = select_dataset(project);

if isnumeric(dataset),
    return;
end;

%% Loading
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);

%% Selecting points
figure(1); clf; hold on;
scatter(coors(:,1), coors(:,2), 10, coors(:,3));

[pind,xs,ys] = selectdata('selectionmode','rect');

coors = coors(pind , :);
waveforms = waveforms(pind);

hold on;
plot(coors(:, 1), coors(:, 2), 'bo');

%% Save

save_name = input(sprintf('The name of the new dataset <%s>: ', save_name_def),'s');
if strcmp(save_name, ''),
    save_name = save_name_def;    
end;
fprintf('Saved: %s\n', save_name)

save([project.result_folder '\' save_name '_coors'] ,'coors');
save([project.result_folder '\' save_name '_waveforms'] ,'waveforms');
save([project.result_folder '\' save_name '_sdf_info'] ,'sdf_info');

project.datasets{length(project.datasets)+1}.name = save_name;
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' save_name '_coors.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' save_name '_waveforms.mat'];
project.datasets{length(project.datasets)}.sdf_info = dataset.sdf_info;
save(project_file, 'project')
