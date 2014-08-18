%%
% Viewer: pick a point and see its waveform and calcualted values
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

clear all; clf; close all;

%% Settings
settings;

load(project_file)

dataset = select_dataset(project);

%% Loading
disp('Loading data...');
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);
disp('Dataset has been loaded!');

fprintf('Point #: %i\n', size(coors,1));
if size(coors,1) ~= length(waveforms),
    disp('Error! the coors and waveforms matrix have different size!')    
    input('Press a key...')
    return;
end;

%% Show viewer
figure(4); clf;
plot3(coors(:,1), coors(:,2), coors(:,3), 'r*');
title('3D view')
axis equal;

figure(1); clf;
title('Press right mouse click!')
scatter(coors(:,1), coors(:,2), 10, coors(:,3));
axis equal;

% vals = zeros(length(waveforms), 1)
% for i = 1 : length(waveforms),
%     rec = waveforms{i};
%     ptr = rec.dirptr;
%     val(i) = ptr(1)+ptr(2)+ptr(3);
% end;
%scatter(coors(:,1), coors(:,2), 10, val');

while 1,

    figure(1);
    [x y] = getpts();

    [~, selp] = min((coors(:,1) - x(1)).^2 + (coors(:,2) - y(1)).^2);
    clf; hold on;

    title('Press right mouse click!')
    scatter(coors(:,1), coors(:,2), 10, coors(:,3));
    %scatter(coors(:,1), coors(:,2), 10, val');
    plot3(coors(selp, 1), coors(selp, 2), coors(selp, 3), 'bo');
    disp(' ');
    disp('Point data from LAS');
    disp('----------------------------------------');
    fprintf('X         [m]    = %.3f\n', coors(selp, 1));
    fprintf('Y         [m]    = %.3f\n', coors(selp, 2));
    fprintf('Z         [m]    = %.3f\n', coors(selp, 3));
    fprintf('Intensity [-]    = %i\n',   coors(selp, 4));
    fprintf('Timestamp [GPST] = %.9f\n', coors(selp, 5));
    fprintf('NOR       [-]    = %i\n',   coors(selp, 6)); % number of return
    fprintf('Scan ang. [m]    = %i\n',   coors(selp, 7)); % scan angle
    
    rec = waveforms{selp};
    
    disp('Waveform data from SDF');
    disp('----------------------------------------');
    %fprintf('Record num: %i\n', rec_num);
    fprintf('Sample blocks: %i\n', rec.sbl_count);
    fprintf('rec sbl no: %i\n', size(rec.sbl,2));
    fprintf('External time: %.9f\n', rec.time_ext);
    
    figure(2); clf; hold on;
    n = double(rec.sbl_count);
    for j = 1 : n,
        fprintf('Channel : %i\n', rec.sbl{j}.channel);
        
        fprintf('Waveform: ');
        samples = rec.sbl{j}.sample;
        for s_i = 1 : length(samples), 
            fprintf('%i ', samples(s_i));
        end;
        fprintf('\n');
        
        subplot(1,n,j); hold on;
        tstart = rec.sbl{j}.time_sosbl;
        stime = sdf_info.sampling_time;
        ts = tstart : stime : (tstart+(length(samples)-1)*stime);       
        plot(ts,samples, 'r*-');

    end;
    
    % Gauss fitting results
    figure(3); hold on;
    clf; hold on;
    
    samples = rec.g_samples;
    tvals = rec.g_ts;
    gaussfn = rec.g_fn;
    xsol = rec.g_params;
    
    plot(tvals ,samples, 'r*-');
    tsol = min(tvals):0.1:max(tvals);
    plot(tsol , gaussfn(tsol , xsol), 'b-');
    fprintf('Gaussian parameters:\n');
    fprintf('                  a: %.4f\n', xsol(1));
    fprintf('                  b: %.4f\n', xsol(2));
    fprintf('                  c: %.4f\n', xsol(3));
    fprintf('                  d: %.4f\n', xsol(4));
    fprintf('                  e: %.4f\n', xsol(5));
    
    fprintf('\n\n');
    fprintf('Time difference [GPST] = %.6f\n', rec.time_ext - coors(selp, 5));
    
    
    hold off;
end;