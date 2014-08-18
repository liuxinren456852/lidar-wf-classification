%%
% Remove points by the z coordinate
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

%% Filtering

x = coors(:,1);
y = coors(:,2);
z = coors(:,3);

h=figure(1); clf; hold on;
scatter3(x, y, z, 10, z);
colorbar;
grid on;

lb = input('Cutting lower bound Z coordinate [-Inf]: ');
if or(~isnumeric(lb), isempty(lb)),
    disp('Use -Inf!');
    lb = -Inf;
end;

ub = input('Cutting upper bound Z coordinate [Inf]: ');
if or(~isnumeric(ub), isempty(ub)),
    disp('Use Inf!');
    ub = Inf;
end;

% Get indeces 
ind = find(and(lb <= z, z <= ub));

coors = coors(ind,:);
waveforms = waveforms(ind);
x_filter = x(ind); 
y_filter = y(ind); 
z_filter = z(ind); 

fprintf('Kept point #: %i\n', length(ind));
fprintf('Removed point #: %i\n', length(x) - length(ind));
disp('Removing done!');

figure(1);
plot3(x_filter, y_filter, z_filter, 'r.')
legend('Original dataset', 'Selected points');
set(gca, 'FontSize', 14);
disp('Displaying done!');

h = figure(1);
saveas(h, [project.result_folder '\filter_z_' dataset.name],'fig');
print(h, '-dpng', [project.result_folder '\filter_z_' dataset.name '.png']);
disp('Image saves done!');

% Save results
save([project.result_folder '\' dataset.name '_coors_z_filt'] ,'coors');
save([project.result_folder '\' dataset.name '_waveforms_z_filt'] ,'waveforms');

project.datasets{length(project.datasets)+1}.name = [dataset.name '_z_filt'];
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' dataset.name '_coors_z_filt.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' dataset.name '_waveforms_z_filt.mat'];
project.datasets{length(project.datasets)}.sdf_info = dataset.sdf_info;
save(project_file, 'project');
disp('Saving project done!');



