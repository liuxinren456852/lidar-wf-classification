%%
% Helping for using toolbox
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
s = '\nCommands:\n';

s = [s, 'las_cut               - Cut region from LAS file using Shape file\n'];
s = [s, 'new_project           - Create new project\n'];
s = [s, 'directions            - Calculate angles of the points\n'];
s = [s, 'load_dataset          - Load dataset to project\n'];
s = [s, 'remove_dataset        - Load dataset from project\n'];
s = [s, 'viewer                - View the datasets\n'];
s = [s, 'select_points         - Select points and create new dataset\n'];
s = [s, 'filter_cloud          - Fit plane to the points and remove points which are far from the plane\n'];
s = [s, 'filter_z              - Remove points by Z coordinates\n'];
s = [s, 'filter_downsampling   - Downsampling the cloud\n'];

s = [s, '\n'];
fprintf(s);