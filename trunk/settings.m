%%
% Settings, load project
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
project = [];

%project_file = 'projects/project_roof1.mat';
%project_file = 'projects/project_roof_two_scanner.mat';

%project_file = 'projects/project_land_class.mat';
project_file = 'projects/project_land_class2.mat';

%project_file = 'projects/project_incangle_road.mat';

% Original return, or impulse response
smpidx = 1; iridx = 2;
wave_id = 1;

% Udsing translated sample vectors?
is_translating = 0;

disp('');
disp(['Project: ', project_file]);
disp('');

