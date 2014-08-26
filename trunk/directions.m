%%
% Laser direction view
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

clear all; clf; close all;

%% Settings
settings;

load(project_file)

save_name_def = 'nan';

[dataset dataset_no] = select_dataset(project);

if isnumeric(dataset),
    return;
end;

%% Loading
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);

%%
figure(1); clf; hold on;
plot3(coors(:,1),coors(:,2), coors(:,3), 'r*');
angles = [];

hw = waitbar(0,'Calculating angles...');
for i = 1:3:length(waveforms),
%for i = 1:10,
               
        perc = i/size(coors, 1);
        waitbar(perc,hw,sprintf('Calculating angles: %.1f%% ',perc*100));
    
        wform = waveforms{i};
        if length(wform.sbl) > 1,
            sample = wform.sbl{2}.sample;
        else
            continue;
        end;
        
        beam_vect = (wform.originptr + wform.dirptr);
        %beam_vect = wform.dirptr;
        beam_vect(1:3) = [beam_vect(3) beam_vect(2) beam_vect(1)];
        beam_vectn = (beam_vect)/ norm(beam_vect)*1;
        beam_vect = beam_vectn;
        %beam_vect = wform.originptr/norm(wform.originptr)*-1;
        h=plot3([coors(i,1), coors(i,1)+beam_vectn(1)],...
              [coors(i,2), coors(i,2)+beam_vectn(2)],...
              [coors(i,3), coors(i,3)+beam_vectn(3)], 'k-');
       set(h, 'LineWidth', 2);
          
       ang = atan(beam_vect(1)/sqrt(beam_vect(2)^2+beam_vect(3)^2))*180/pi;
       angles = [angles; coors(i,7) ang];
        
       h=xlabel('X [m]'); set(h, 'FontSize', 12);
       h=ylabel('Y [m]'); set(h, 'FontSize', 12);
       h=zlabel('Z [m]'); set(h, 'FontSize', 12);
end;
grid on;
axis equal;

% Compare LAS and angles computed from SDF
figure(2); clf; hold on;
unangles = unique(angles(:,1));
sel_angle = unangles(1);
rangs = find(angles(:,1)==sel_angle);
plot(1:length(rangs), angles(rangs, 2), 'r-');
h=plot(1:length(rangs), repmat(abs(sel_angle) + 0.5, 1, length(rangs)), 'k--');
set(h, 'LineWidth', 2);
h=plot(1:length(rangs), repmat(abs(sel_angle) - 0.5, 1, length(rangs)), 'k--');
set(h, 'LineWidth', 2);
title(sprintf('LAS scan angle: %i^o', sel_angle));
%ylim([10 13]);
h = xlabel('Sample [#]'); 
set(h, 'LineWidth', 12);
h=ylabel('Calculated scan angle [^o]');
set(h, 'LineWidth', 12);

% Save results
dataset.angles = angles;
project.datasets{dataset_no} = dataset;
save(project_file, 'project');

          