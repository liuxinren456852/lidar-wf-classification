%%
% Downsampling the cloud
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Settings
clear all;
settings;

load(project_file)

sigma_rule = 3;
max_dist = 0.3;
dataset = select_dataset(project);

if isnumeric(dataset),
    return;
end;

%% Loading
disp('Loading data...');
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);
disp('Dataset has been loaded!');

if size(coors,1) ~= length(waveforms),
    disp('Error! the coors and waveforms matrix have different size!')    
    return;
end;

step = input('Step size [10]: ');
if or(~isnumeric(step), isempty(step)),
    disp('Use 10!');
    step = 10;
end;

prev_point_num = size(coors, 1);
ind = 1 : step : size(coors);
coors = coors(ind,:);
waveforms = waveforms(ind);

fprintf('Kept point #: %i\n', length(ind));
fprintf('Removed point #: %i\n', prev_point_num - length(ind));
disp('Removing done!');

% Save results
save([project.result_folder '\' dataset.name '_coors_ds'] ,'coors');
save([project.result_folder '\' dataset.name '_waveforms_ds'] ,'waveforms');

project.datasets{length(project.datasets)+1}.name = [dataset.name '_ds'];
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' dataset.name '_coors_ds.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' dataset.name '_waveforms_ds.mat'];
project.datasets{length(project.datasets)}.ds_rate = step;
project.datasets{length(project.datasets)}.sdf_info = dataset.sdf_info;
save(project_file, 'project');
disp('Saving project done!');