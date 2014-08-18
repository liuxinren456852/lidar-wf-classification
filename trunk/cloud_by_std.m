%%
% 
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Settings
settings;
dataset = 'datatset_7';


%% Loading
load([result_folder '\' dataset '_coors']);
load([result_folder '\' dataset '_waveforms']);
load([result_folder '\' dataset '_sdf_info']);

vals = zeros(size(coors,1), 1);
for i = 1 : 1 : size(coors,1),
    vals(i) = waveforms{i}.g_params(2);
end;

figure(1); clf; hold on;
scatter3(coors(:,1), coors(:,2), coors(:,3), 10, vals);
grid on;
axis equal;

figure(2); clf; hold on;
hist(vals, 100)