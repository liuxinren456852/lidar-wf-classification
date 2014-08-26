%%
% Calcualte Gaussian parameters
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Gaussian parameters
from_id = 0;

s = '';
h0=figure(2); clf; hold on;
fig_num = 0;
limits = [];
disp('Gathering Gaussian parameters...')
for i = 1 : length(groups),
    fprintf('Group: %s\n', groups{i}.name);
    
    g_params = groups{i}.g_params{wave_id};
    
    % Calculate mean and std
    groups{i}.m_g_params = mean(g_params);
    groups{i}.std_g_params = std(g_params);
    
    % Create text
    s = [s, sprintf('Dataset %i, avg, %.3f, %.3f, %.3f, %.3f, %.3f\n', i, groups{i}.m_g_params)];
    s = [s, sprintf('Dataset %i, std, %.3f, %.3f, %.3f, %.3f, %.3f\n', i, groups{i}.std_g_params)];    
    
    % Display results
    for j = 1:size(g_params, 2);
        fig_num = fig_num + 1;
        subplot(length(groups),5, fig_num);
        vals = g_params(:,j);
        hist(vals, 50);
           
        limits = [limits; mean(vals)-2*std(vals) mean(vals)+2*std(vals)];
    end;
    
end;
fprintf(s);
disp('Done!')

% Setting xlims
fig_num = 0;
%limits = [0 400; 0 30; 0 6; 0 10; 1.9 2.1];
for i = 1 : length(groups),
    for j = 1:size(g_params, 2),
       
        xmin = min(limits(j:5:end, 1));
        xmax = max(limits(j:5:end, 2));
        
        fig_num = fig_num + 1;
        h=subplot(length(groups), 5, fig_num); hold off;
        vals = groups{i}.g_params{wave_id}(:,j);
        vals_red = vals(and(vals>xmin, vals<xmax));
        hist(vals_red, 20);
        xlim([xmin, xmax]);
        %h = xlabel('Value'); set(h, 'FontSize', 14);
        %h = ylabel('[-]'); set(h, 'FontSize', 14);
        h = title(sprintf('%s p_%i', groups{i}.name, j));
        set(h, 'FontSize', 14);  
        set(gca, 'FontSize', 12);
        grid on;
        
    end;
end;


fid = fopen([project.result_folder '\' project.name '_guass.csv'],'w');            
fprintf(fid,'%s\r\n',s);       
fclose(fid);

%% Typical waveforms

figure(3); clf; hold on;
figure(4); clf; hold on;
for gi = 1 : length(groups)
          
    figure(3);
    subplot(length(groups),1,gi); hold on;
    if is_translating == 1,
        cw = trans_waveform(groups{gi}.wfmx{wave_id}, -1);
    else
        cw = groups{gi}.wfmx{wave_id};
    end;
    
    %h = plot(1:size(cw, 2), mean(cw), 'r-');
    hp{gi}(1) = plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), mean(cw), 1:0.2:size(cw, 2)), 'r-');
    labels{gi}{1} = 'Average';
    set(hp{gi}(1), 'LineWidth', 3)
    
    %plot(1:size(cw, 2), mean(cw)+std(cw), 'r--');
    %plot(1:size(cw, 2), mean(cw)-std(cw), 'r--');
    hp{gi}(2) = plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), mean(cw)+std(cw), 1:0.2:size(cw, 2)), 'r--');
    labels{gi}{2} = 'Std';
    plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), mean(cw)-std(cw), 1:0.2:size(cw, 2)), 'r--');
    
    %h = plot(1:size(cw, 2), median(cw), 'b-');
    hp{gi}(3) = plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), median(cw), 1:0.2:size(cw, 2)), 'b-');
    labels{gi}{3} = 'Median';
    set(hp{gi}(3), 'LineWidth', 3)
    
    %h=plot(1:size(cw, 2), max(cw), 'k-');
    h=plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), max(cw), 1:0.2:size(cw, 2)), 'k-');
    set(h, 'LineWidth', 2)
    
    %h = plot(1:size(cw, 2), min(cw), 'k-');
    hp{gi}(4) = plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), min(cw), 1:0.2:size(cw, 2)), 'k-');
    labels{gi}{4} = 'Min, Max';
    set(hp{gi}(4), 'LineWidth', 2)

    h=title(groups{gi}.name);
    set(h, 'FontSize', 12);
    grid on;
    
    ylim([0 300]);
    
    % Median waveforms
    figure(4); hold on;
    xval = 1:0.2:size(cw, 2);
    xvals = 1:1:size(cw, 2);
    hp3(gi) = plot(from_id + xval, spline(xvals, median(cw), 1:0.2:size(cw, 2)), [colors(gi) '-']); 
    set(hp3(gi), 'LineWidth', 3);
    plot(from_id + xval, spline(xvals, median(cw)+mad(cw), 1:0.2:size(cw, 2)), [colors(gi) '--']); 
    plot(from_id + xval, spline(xvals, median(cw)-mad(cw), 1:0.2:size(cw, 2)), [colors(gi) '--']);
    labels3{gi} = groups{gi}.name;
    set(hp3(gi), 'LineWidth', 2);
    %xlim([15 60]);
    grid on;
    
%     % Save median wavform
%     groups{gi}.median_wf = median(cw);
%     groups{gi}.mean_wf = median(cw);
%     groups{gi}.min_wf = min(cw);
%     groups{gi}.median_lower_mad_wf = median(cw)-mad(cw);
%     groups{gi}.median_upper_mad_wf = median(cw)+mad(cw);
%     
%     % Use transform waveforms
%     cw_t = trans_waveform(cw, -1);
%     groups{gi}.median_wf_t = median(cw_t);
%     groups{gi}.mean_wf_t = median(cw_t);
%     groups{gi}.min_wf_t = min(cw_t);
%     groups{gi}.median_lower_mad_wf_t = median(cw_t)-mad(cw_t);
%     groups{gi}.median_upper_mad_wf_t = median(cw_t)+mad(cw_t);

end;

% Set legend and axis labels
h1=figure(3);
for figi = 1 : length(groups),
    subplot(length(groups),1,figi); 
    h = legend(hp{figi}, labels{figi});
    set(h, 'FontSize', 12);
    h=xlabel('Sample #'); set(h, 'FontSize', 12);
    h=ylabel('Intensity'); set(h, 'FontSize', 12);    
end

% Set legend and axis labels of median waveforms
h2=figure(4);
h=legend(hp3, labels3);
set(h, 'FontSize', 12);
h=title('Median Waveforms');
set(h, 'FontSize', 12);
h=xlabel('Sample #'); set(h, 'FontSize', 12);
h=ylabel('Intensity'); set(h, 'FontSize', 12);
set(gca, 'FontSize', 12);

% Save the figures
saveas(h0, [project.result_folder '\' project.name '_gauss_hist.png'],'png');
saveas(h1, [project.result_folder '\' project.name '_typwf.png'],'png');
saveas(h2, [project.result_folder '\' project.name '_medwf.png'],'png');



