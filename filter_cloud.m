%%
% Remove outliers from the point cloud which is not enough close to the
% fitting plane
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
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);

%% Filtering

x = coors(:,1);
y = coors(:,2);
z = coors(:,3);

% Use center coordinates
x = x - mean(x);
y = y - mean(y);
z = z - mean(z);

figure(1); clf; hold on;
plot3(x, y, z, 'r*')

% Fit plane
f = fit( [x, y], z, 'poly11' );
plot(f, [x,y], z);
axis equal;

% Calculate STD
stdval = std(z - f(x,y));
p = coeffvalues(f);

% Get indeces 
ind = find(and( abs(z - f(x,y)) < (stdval * sigma_rule), abs(z - f(x,y)) < max_dist) );

coors = coors(ind,:);
waveforms = waveforms(ind);
x_filter = x(ind); 
y_filter = y(ind); 
z_filter = z(ind); 
plot3(x_filter, y_filter, z_filter, 'ro')

% Fit plane again to check
f = fit( [x_filter, y_filter], z_filter, 'poly11' );
p2 = coeffvalues(f);
stdval_filter = std(z_filter - f(x_filter,y_filter));
    
legend('Original dataset', 'Fitting plane', 'Original dataset', 'Selected points');
set(gca, 'FontSize', 14);

%% Plotting
s = [];
s = [s, sprintf('\nResults:\n')];
s = [s, sprintf('Fitting plane:           %.6fx + %.6fy + %.6f\n', p(2), p(3), p(1))];
s = [s, sprintf('Standard deviation:      %.3f m\n', stdval)];
s = [s, sprintf('Filtered plane:          %.6fx + %.6fy + %.6f\n', p2(2), p2(3), p2(1))];
s = [s, sprintf('STD from filtered plane: %.3f m\n', stdval_filter)];
s = [s, sprintf('No. of original dataset: %i\n', length(x))];
s = [s, sprintf('No. of removed points:   %i\n', length(x)-length(x_filter))];
s = [s, sprintf('No. of filtered points:  %i\n', length(x_filter))];
s = [s, sprintf('\n')];

disp(s);

%% Saving results
save([project.result_folder '\' dataset.name '_coors_filtered'] ,'coors');
save([project.result_folder '\' dataset.name '_waveforms_filtered'] ,'waveforms');

h = figure(1);
saveas(h,[project.result_folder '\' dataset.name '_fig_filtered'],'fig');

fid = fopen([project.result_folder '\' dataset.name '_stat_filtered.txt'],'w');            
fprintf(fid,'%s\r\n',s);       
fclose(fid);     

project.datasets{length(project.datasets)+1}.name = [dataset.name '_filtered'];
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' dataset.name '_coors_filtered.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' dataset.name '_waveforms_filtered.mat'];
project.datasets{length(project.datasets)}.sdf_info = dataset.sdf_info;
save(project_file, 'project')



