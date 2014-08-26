%%
% Load the dataset to the project and pair the LAS and the SDF records
% Calculate gaussian parameters
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%

clear all; clc; close all;

% Load SDF reader library
addpath('sdf_reader');

%% Settigns
settings
load(project_file)

% Load LAS file
[las_file, las_folder, FilterIndex] = uigetfile({'*.las'}, 'Select the LAS file...', 'MultiSelect', 'off');
if las_file == 0,
    disp('No selected file! Return!')
    return;
end;

% Load SDF file
[sdf_file, sdf_folder, FilterIndex] = uigetfile({'*.sdf'}, 'Select the SDF file...', 'MultiSelect', 'off');
if sdf_file == 0,
    disp('No selected file! Return!')
    return;
end;

% Set ouput file
save_name = input('What will be the nam of the new dataset: ', 's');
if isempty(save_name),
    disp('No output file specified! Return!')
    return;
end;

%% Load SDF file
[names,notfound,warnings]=load_fwifc;
[res, fileptr] = fwifc_open([sdf_folder '\' sdf_file]);

[res, lib_ver] = fwifc_get_library_version;
disp('Library version:'); disp(lib_ver);

[res, sdf_info] = fwifc_get_info( fileptr )

save([project.result_folder '\' save_name '_sdf_info'] ,'sdf_info');

%% Load LAS file
% For header
%lasread([folder '\' filename '.las'])

% If waveform available
%dos(['las2txt.exe -i "', folder, '\', filename '.las" -parse xyzitar -sep comma -parse WV']);
dos(['las2txt.exe -i "', las_folder, '\', las_file '" -o "' project.result_folder '\' las_file '.txt" -parse xyzitra -sep comma -keep_single']);
coors = dlmread([project.result_folder, '\', las_file, '.txt' ]);
coors = coors(coors(:,6)==1,:);

%% Matching LAS and SDF
h = waitbar(0,'Matching point cloud and waveforms...');
diff_ts = zeros(size(coors, 1), 1);
diff_next_ext_ts = zeros(size(coors, 1), 1);
for i = 1 : size(coors, 1),
    perc = i/size(coors, 1);
    waitbar(perc,h,sprintf('Matching point cloud and waveforms: %.1f%% ',perc*100));
    ts = coors(i, 5);
    res = fwifc_seek_time_external( fileptr, ts);
    waveforms{i} = fwifc_read( fileptr ); 

    diff_ts(i) = waveforms{i}.time_ext - ts;
    fprintf('SDF-LAS:     %.9f %.9f %.9f\n', waveforms{i}.time_ext, ts, diff_ts(i));    
    [res, rec_num] = fwifc_tell( fileptr );
    rec = fwifc_read( fileptr ); 
    diff_next_ext_ts(i) = rec.time_ext - waveforms{i}.time_ext;
    fprintf('EXT_TS_DIFF: %.9f %.9f %.9f\n', waveforms{i}.time_ext, rec.time_ext, diff_next_ext_ts(i));    
end;
close(h);

res = fwifc_close( fileptr );

save([project.result_folder '\' save_name '_coors'] ,'coors');
save([project.result_folder '\' save_name '_waveforms'] ,'waveforms');

project.datasets{length(project.datasets)+1}.name = save_name;
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' save_name '_coors.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' save_name '_waveforms.mat'];
project.datasets{length(project.datasets)}.sdf_info = [project.result_folder '\' save_name '_sdf_info.mat'];
save(project_file, 'project')

%% Update project
project.datasets{length(project.datasets)}.name = save_name;
project.datasets{length(project.datasets)}.coors = [project.result_folder '\' save_name '_coors.mat'];
project.datasets{length(project.datasets)}.waveforms = [project.result_folder '\' save_name '_waveforms.mat'];
project.datasets{length(project.datasets)}.sdf_info = [project.result_folder '\' save_name '_sdf_info.mat'];
save(project_file, 'project')





