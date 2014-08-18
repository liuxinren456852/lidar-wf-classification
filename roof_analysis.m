%%
% TODO: ...
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Settings
clear all; clc; close all;

settings;

dataset_1 = 'dataset_71';
dataset_2 = 'dataset_72';

%filtered = '_filtered';
filtered = '';

colors = 'rgbcykm'

%% Loadings
load([result_folder '\' dataset_1 '_coors' filtered]);
load([result_folder '\' dataset_1 '_waveforms' filtered]);
load([result_folder '\' dataset_1 '_sdf_info']);

group{1}.coors = coors;
group{1}.waveforms = waveforms;
group{1}.sdf_info = sdf_info;
group{1}.wfmx = get_sample_to_mx(group{1}.waveforms, 2);
group{1}.name = 'Dataset 1';

load([result_folder '\' dataset_2 '_coors' filtered]);
load([result_folder '\' dataset_2 '_waveforms' filtered]);
load([result_folder '\' dataset_2 '_sdf_info']);

group{2}.coors = coors;
group{2}.waveforms = waveforms;
group{2}.sdf_info = sdf_info;
group{2}.wfmx = get_sample_to_mx(group{2}.waveforms, 2);
group{2}.name = 'Dataset 2';

%% Display dataset
figure(1); clf; hold on;
for i = 1 : length(group),
    h(i) = plot3(group{i}.coors(:,1), group{i}.coors(:,2), group{i}.coors(:,3), [colors(i), '*']);
    h_name{i} = group{i}.name;
end
grid on;
h=legend(h, h_name);
set(h, 'FontSize', 14);
h=xlabel('X [m]'); set(h, 'FontSize', 14);
h=ylabel('Y [m]'); set(h, 'FontSize', 14);
h=zlabel('Z [m]');set(h, 'FontSize', 14);

set(gca, 'FontSize', 10);
axis equal;


%% Gaussian parameters
s = '';
figure(2); clf; hold on;
fig_num = 0;
for i = 1 : length(group),
    group{i}.g_params = get_gaussian_param_to_mx( group{i}.waveforms );
    g_params = group{i}.g_params;
    group{i}.m_g_params = mean(g_params);
    group{i}.std_g_params = std(g_params);
    s = [s, sprintf('Dataset %i, avg, %.3f, %.3f, %.3f, %.3f, %.3f\n', i, group{i}.m_g_params)];
    s = [s, sprintf('Dataset %i, std, %.3f, %.3f, %.3f, %.3f, %.3f\n', i, group{i}.std_g_params)];
    
    
    for j = 1:size(g_params, 2);
        fig_num = fig_num + 1;
        subplot(length(group),5, fig_num);
        hist(group{i}.g_params(:,j), 50);
        h=title(sprintf('Dataset %i p_%i', i, j));
        set(h, 'FontSize', 14);  
        set(gca, 'FontSize', 12);    
    end;
end;
fprintf(s);

fid = fopen([result_folder '\' dataset_1 '_' dataset_2 '_guass' filtered '.csv'],'w');            
fprintf(fid,'%s\r\n',s);       
fclose(fid);

%% Typical waveforms
figure(3); clf; hold on;
colors = 'rgbcyk'
for gi = 1 : 2
           
    subplot(3,1,gi); hold on;
    cw = group{gi}.wfmx;
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

    h=title(['Dataset ' num2str(gi)]);
    set(h, 'FontSize', 12);
    grid on;
    
    ylim([0 250]);
    
    subplot(3,1,3); hold on;
    hp3(gi) = plot(1:0.2:size(cw, 2), spline(1:size(cw, 2), median(cw), 1:0.2:size(cw, 2)), [colors(gi) '-']);    
    labels3{gi} = ['Dataset ' num2str(gi)];
    set(hp3(gi), 'LineWidth', 2);
    xlim([10 30]);
    grid on;

end;

for figi = 1 : 2
    subplot(3,1,figi); 
    h = legend(hp{figi}, labels{figi});
    set(h, 'FontSize', 12);
    h=xlabel('Sample #'); set(h, 'FontSize', 12);
    h=ylabel('Intensity'); set(h, 'FontSize', 12);
    
end

subplot(3,1,3); 
h=legend(hp3, labels3);
set(h, 'FontSize', 12);
h=title('Dataset 1 and 2 Median Waveforms');
set(h, 'FontSize', 12);
h=xlabel('Sample #'); set(h, 'FontSize', 12);
h=ylabel('Intensity'); set(h, 'FontSize', 12);
set(gca, 'FontSize', 12);

return;

%% Skewness and kurtosis
% figure(4); clf; hold on;
% figure(5); clf; hold on;
% colors = 'rgbcyk';
% sumkurt = [];
% for gi = 1 : 2
%     skl = skewness(group{gi}.wfmx(:, 1:40), 1, 2);
%     kurtl = kurtosis(group{gi}.wfmx(:, 1:40), 1, 2);
%     
%     mskl = mean(skl); sskl = std(skl)/2;
%     mkurtl = mean(kurtl); skurtl = std(kurtl)/2;
%     
%     skl = skl(and((mskl-sskl)<skl, skl<(mskl+sskl)));
%     kurtl = kurtl(and((mkurtl-skurtl)<kurtl, kurtl<(mkurtl+skurtl)));
%     
%     sk{gi} = skl;
%     kurt{gi} = kurtl;
%     
%     sumkurt = [sumkurt; repmat(gi, length(kurtl), 1), kurtl];
%     
%     figure(4);
%     subplot(1,2,gi); hold on;
%     hist(sk{gi}, 10);
%     title(['Skewness - Dataset ' num2str(gi)])
%     h=plot([mean(skl), mean(skl)], [0 30], 'r-');
%     set(h, 'LineWidth', 2);
%     h=plot([median(skl), median(skl)], [0 30], 'g-');
%     set(h, 'LineWidth', 2);
%     xlabel('Value [ns]'); ylabel('Freq [-]');
%     %xlim([3 3.2])
%     
%     figure(5);
%     subplot(1,2,gi); hold on;
%     hist(kurt{gi}, 10);
%     title(['Kurtosis - Dataset ' num2str(gi)])
%     h=plot([mean(kurtl), mean(kurtl)], [0 45], 'r-');
%     set(h, 'LineWidth', 2);
%     h=plot([median(kurtl), median(kurtl)], [0 45], 'g-');
%     set(h, 'LineWidth', 2);
%     xlabel('Value [ns]'); ylabel('Freq [-]');
%     %xlim([10 14])
%     
%     fprintf('Dataset %i, %.3f, %.3f, %.3f, %.3f\n', gi, mean(skl), median(skl), mean(kurtl), median(kurtl));
% 
% end;

%% Neural network
nn_results = 'nn_results';
run_name = 'run1';

sum_samples = [];
for gi = 1 : 2
    sample = group{gi}.wfmx(:, 1:40);
    %sample = trans_waveform(sample, -1);
    sum_samples = [sum_samples; repmat(gi, size(sample, 1), 1), sample];
end;

inputs = sum_samples(:,2:end)';
targets = sum_samples(:,1)';

targets(targets==1)=0;
targets(targets==2)=1;

% Create a Pattern Recognition Network
hiddenLayerSize = [5 10];
net = patternnet(hiddenLayerSize);

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

% View the Network
%view(net)

lb = 0.22; ub = 1-lb;

figure(8); clf; hold on;
indf = find(or(outputs < lb, outputs > ub));
targetsc = targets(indf); outputsc = outputs(indf);
plotconfusion(targetsc,outputsc)
h=title('Overall');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(8);
print(h, '-dpng', [nn_results '\cm_over_' num2str(lb) '_' run_name '.png']);

figure(9); clf; hold on;
inputsl = inputs(:,tr.trainInd);
targetl = targets(tr.trainInd);
outputsl = net(inputsl);
ind = find(or(outputsl < lb, outputsl > ub));
targetlc = targetl(ind); outputslc = outputsl(ind);
plotconfusion(targetlc,outputslc)
h=title('Train');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(9);
print(h, '-dpng', [nn_results '\cm_train_' num2str(lb) '_' run_name '.png']);

figure(10); clf; hold on;
inputsl = inputs(:,tr.valInd);
targetl = targets(tr.valInd);
outputsl = net(inputsl);
ind = find(or(outputsl < lb, outputsl > ub));
targetlc = targetl(ind); outputslc = outputsl(ind);
plotconfusion(targetlc,outputslc)
h=title('Validation');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(10);
print(h, '-dpng', [nn_results '\cm_valid_' num2str(lb) '_' run_name '.png']);

figure(11); clf; hold on;
inputsl = inputs(:,tr.testInd);
targetl = targets(tr.testInd);
outputsl = net(inputsl);
ind = find(or(outputsl < lb, outputsl > ub));
targetlc = targetl(ind); outputslc = outputsl(ind);
plotconfusion(targetlc,outputslc)
h=title('Test');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(11);
print(h, '-dpng', [nn_results '\cm_test_' num2str(lb) '_' run_name '.png']);


fprintf('Bound: %.1f\nNo. of points: %i\nNo. of selected points: %i (%.1f%%)\n', lb, length(outputs), length(indf), length(indf)/length(outputs)*100);

% Histogram of the differences
% figure(12); clf; hold on;
% hist(outputs,20);


% Show the typical waveforms
figure(7); clf; hold on;
inputsc = inputs(:, indf)';

inputsc1 = inputsc(targetsc==0, :);
inputsc2 = inputsc(targetsc==1, :);

%subplot(1,2,1); hold on;
for i = 1 : size(inputsc1,1),
    cw = inputsc1(i,:);
    %plot(1:length(cw), cw, 'r*-');
    h1=plot(1:0.2:length(cw), spline(1:size(cw, 2), cw, 1:0.2:size(cw, 2)), 'r-');
end;
ylim([0 150]); xlim([10 30]);

%subplot(1,2,2); hold on;
for i = 1 : size(inputsc2,1),
    cw = inputsc2(i,:);
    %plot(1:length(cw), cw, 'r*-');
    h2=plot(1:0.2:length(cw), spline(1:size(cw, 2), cw, 1:0.2:size(cw, 2)), 'g-');
end;
legend([h1,h2], {'Dataset 1','Dataset 2'});
ylim([0 150]); xlim([10 30]);
h = xlabel('Time [ns]'); set(h, 'FontSize', 14);
h = ylabel('Intensity'); set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(7);
print(h, '-dpng', [nn_results '\wfs_' num2str(lb) '_' run_name '.png']);





