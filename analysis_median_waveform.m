
from_digits = 10;
to_digits = 40;

%% Gathering waveforms into one matrix
sum_wfmx = [];
sum_coors = [];
classes = [];
for i = 1 : length(groups),   
    wfmx = groups{i}.wfmx(:,from_digits:to_digits);
    sum_wfmx = [sum_wfmx; wfmx];
    classes = [classes; repmat(i, size(wfmx, 1), 1)];   
    
    load(project.datasets{groups{i}.datasets}.coors);
    sum_coors = [sum_coors; coors];
end;

% Checking coors and wfmx matrices size
if size(sum_coors, 1) ~= size(sum_coors, 1)
    disp('Waveforms and coordinate matrix are not same size!')
    input('Press any key...');
    return;
end;

% Translating waveforms
%disp('Translating waveforms...')
%sum_wfmx = trans_waveform(sum_wfmx, -1);

class_vals = zeros(size(sum_wfmx, 1), length(groups));
for i = 1 : length(groups),
    
    fprintf('Group: %s\n', groups{i}.name);
    
    % Reference waveform
    %mwf = trans_waveform(groups{i}.median_wf(from_digits:to_digits), -1);
    %mwf = groups{i}.median_lower_mad_wf(from_digits:to_digits);
    mwf = groups{i}.median_wf(from_digits:to_digits);
    
    % Calculate waveform distances
    diff_wf = sum_wfmx - repmat(mwf, size(sum_wfmx, 1), 1);
    
    % Measuring calculate distance
    %class_vals(:,i) = sum(abs(diff_wf),2);
    class_vals(:,i) = max(abs(diff_wf), [], 2);
end;

% Get chossen groups
[val, ind] = min(class_vals, [], 2);

%% Examining bounds

data_ratio_rate = [Inf 3 2 1 2/3 0.5 1/3 0.2];
%data_ratio_rate = [3 2 1.5 1 2/3 0.5];
graph_lines = [];
for j = 1 : length(data_ratio_rate),
    
    % Filter dataset
    %sel = 1 : size(classes, 1);
    sel = find( val < ( mean(val) * data_ratio_rate(j) ) );
    data_ratio = length(sel)/length(val);
    
    % No data by filters
    if isempty(sel),
        continue;
    end;

    % Confusion matrix
    cmat = confusionmat(classes(sel), ind(sel));
    
    % Save result
    dlmwrite([project.result_folder '\anal_median_wf_' project.name '_' num2str(data_ratio_rate(j)) '.csv'], cmat);

    % Calculate positive and negative mismatches
    false_positives = [];
    false_negatives = [];
    perc_fp = []; perc_fn = [];
    for i = 1 : length(groups),
        false_negatives = [false_negatives; sum(cmat(i,:)) - cmat(i,i)];
        perc_fn = [perc_fn;  (cmat(i,i) / sum(cmat(i,:)) )];
        false_positives = [false_positives, sum(cmat(:,i)) - cmat(i,i)];
        perc_fp = [perc_fp,  (cmat(i,i) / sum(cmat(:,i)) )];
    end;

    % Plot
    if j == 1,
        figure(2); clf; hold on;
        plot3(sum_coors(:, 1), sum_coors(:, 2), sum_coors(:, 3), 'k.');
        for gi = 1 : length(groups),
            gind = find(ind(sel) == gi);
            plot3(sum_coors(gind, 1), sum_coors(gind, 2), sum_coors(gind, 3), [colors(gi), '.']);
        end;
    end;
    
    % Ratios
    oratio = sum(diag(cmat)) / sum(sum(cmat));    
    
    % Extend confusion matrix
    cmat2 = [cmat,false_negatives; false_positives, sum([false_positives, false_negatives'])];
    
    % Graphs for displayin
    graph_lines = [graph_lines; data_ratio_rate(j), data_ratio, oratio, perc_fn', perc_fp];
end;


%% Plotting
legend_label = {};
legend_label_i = 0;
legend_handles= [];


figure(1); clf; hold on;
h = plot(graph_lines(:,1), graph_lines(:,2)*100, 'r.-');
set(h, 'LineWidth', 3);
legend_handles = [legend_handles, h];
legend_label_i = legend_label_i + 1;
legend_label{legend_label_i} = 'Data ratio';

h = plot(graph_lines(:,1), graph_lines(:,3)*100, 'k.-');
set(h, 'LineWidth', 3);
legend_handles = [legend_handles, h];
legend_label_i = legend_label_i + 1;
legend_label{legend_label_i} = 'Overall matches';


for i = 1 : length(groups),
    h = plot(graph_lines(:,1), (1-graph_lines(:,3+i))*100, [colors(i) '.--']);
    legend_handles = [legend_handles, h];
    legend_label_i = legend_label_i + 1;
    legend_label{legend_label_i} = [groups{i}.name ' false positive'];
end;

for i = 1 : length(groups),
    h = plot(graph_lines(:,1), (1-graph_lines(:,3+length(groups)+i))*100, [colors(i) '.:']);
    legend_handles = [legend_handles, h];
    legend_label_i = legend_label_i + 1;
    legend_label{legend_label_i} = [groups{i}.name ' false negative'];
end;

legend(legend_handles, legend_label, 'Location', 'BestOutside');

h = xlabel('n*\sigma [-]'); set(h, 'FontSize', 14);
h = ylabel('[%]'); set(h, 'FontSize', 14);

set(gca, 'FontSize', 14);
%grid on;

 