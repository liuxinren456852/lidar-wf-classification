% Extracting waveform data from Riegl SDF file - Matlab interface

% Tested on Matlab R2013 x64
% Prerequeists:
% - Matlab x64 (if DLL not changed)
% - Microsoft Windows SDK for Windows 7 and .NET Framework 4
%       Download: http://www.microsoft.com/en-us/download/details.aspx?id=8279
%   or other working for Matlab MEX compiler
% - Set up MEX compiler if not done already. Run mex -setup in Matlab's Command Window

% Written by Zoltan Koppanyi
% The Ohio State University
% 2014.06.26

% Changed by Grzegorz Jozkow
% The Ohio State University
% 2014.07.16

%% Emptying workspace and Matlab's Command Window
clear all; clc; 

%% Library
% Loading DLL
[names,notfound,warnings]=load_fwifc;

% Displaying functions
libfunctions('sdfifc');

% Library version info
[res, lib_ver] = fwifc_get_library_version;
disp('Library version:');disp(lib_ver);

%% File
% Opening file
[File,Path,~] = uigetfile('*.sdf','Slect SDF file',...
    'C:\Users\jozkow.1\Desktop\waveform\waveforms-example\130617_192721_1.sdf');
sdffile=fullfile(Path,File);
[res, fileptr] = fwifc_open (sdffile);

% Reindexing
%res = fwifc_reindex(fileptr);

% Getting file info
[res, sdf_info] = fwifc_get_info(fileptr);
disp('SDF file info:');disp(sdf_info);

%% Other
% Getting calibration table (additional license necessary) / not tested
[res, calib_table] = fwifc_get_calib ( fileptr, 2 )
%disp('Calibration table:');disp(calib_table);

% Getting last error
[res, message] = fwifc_get_last_error;
disp(['Last error: ' message]);

% Setting time relative
res = fwifc_set_sosbl_relative( fileptr, 1 );

% Setting time absolute
res = fwifc_set_sosbl_relative( fileptr, 0 );

%% Getting specific records data
% Getting number of records
res = fwifc_seek ( fileptr, 4294967295);
[res, nofrec] = fwifc_tell ( fileptr );
disp(['Number of records: ', num2str(nofrec)]);

% Jump by the record ID
res = fwifc_seek( fileptr, 8393374);
rec_id = fwifc_read( fileptr );
rec_id

% Jump by the time
res = fwifc_seek_time( fileptr, 2957.0);
rec_time = fwifc_read( fileptr );
rec_time

% Jump by the external time
res = fwifc_seek_time_external( fileptr, 156445.0);
rec_time_ext = fwifc_read( fileptr );
rec_time_ext

% Reading records
for i = 1 : 10,
    [res, rec_num]  = fwifc_tell(fileptr);
    rec = fwifc_read( fileptr );

    fprintf('\n----------------\n');
    fprintf('Record num: %i\n', rec_num);
    fprintf('Sample blocks: %i\n', rec.sbl_count);
    fprintf('rec sbl no: %i\n', size(rec.sbl,2));
    fprintf('External time: %.6f\n', rec.time_ext);
    
    for j = 1 : rec.sbl_count,
        fprintf('Channel : %i\n', rec.sbl{j}.channel);
        
        fprintf('Waveform: ');
        samples = rec.sbl{j}.sample;
        for s_i = 1 : length(samples), 
            fprintf('%i ', samples(s_i));
        end;
        fprintf('\n');
    end;
    fprintf('----------------\n');
end;


% Close file
res = fwifc_close( fileptr );
