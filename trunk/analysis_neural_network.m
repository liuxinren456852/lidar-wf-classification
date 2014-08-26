
%% Neural network

%lb = 0.22;
%lb = 0.5; 

ub = 1-lb;

sum_samples = [];
sum_coors = [];

for i = 1 : length(groups),
    
    for j = 1:length(groups{i}.datasets)
        load( project.datasets{groups{i}.datasets(j)}.coors );
        sum_coors = [sum_coors; coors];
    end;

    wfmx = groups{i}.wfmx{wave_id};
    sample = wfmx(:, 1:60);
    sum_samples = [sum_samples; repmat(i-1, size(sample, 1), 1), sample];
end;

% Get inputs and targets
inputs = trans_waveform(sum_samples(:,2:end), -1)';
%inputs = sum_samples(:,2:end)';

%inputs = sum_samples(:,2:end)';
targets = sum_samples(:,1)';


% Create a Pattern Recognition Network
hiddenLayerSize = [5 10];
net = patternnet(hiddenLayerSize);

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 60/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 25/100;

% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs);

% View the Network
%view(net)

figure(8); clf; hold on;
indf = find(or(outputs < lb, outputs > ub));
targetsc = targets(indf); outputsc = outputs(indf);
plotconfusion(targetsc,outputsc)
h=title('Overall');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(8);
print(h, '-dpng', [project.result_folder '\cm_over_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\cm_train_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\cm_valid_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\cm_test_' num2str(lb) '_' project.name '.png']);


fprintf('Bound: %.1f\nNo. of points: %i\nNo. of selected points: %i (%.1f%%)\n', lb, length(outputs), length(indf), length(indf)/length(outputs)*100);

% Histogram of the differences
hf=figure(12); clf; hold on;
hist(outputs,20);
h = xlabel('Responses (Classes)'); set(h, 'FontSize', 14)
h = ylabel('[-]'); set(h, 'FontSize', 14)
h=title('Neural network responses');
set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
xlim([0 1]);
print(hf, '-dpng', [project.result_folder '\nn_hist_' num2str(lb) '_' project.name '.png']);


% Show the typical waveforms
figure(7); clf; hold on;
inputsc = inputs(:, indf)';

inputsc1 = inputsc(targetsc==0, :);
inputsc2 = inputsc(targetsc==1, :);

if or(length(inputsc1) == 0, length(inputsc2) == 0),
    disp('Too low lower bound! No resutls!');
    return;
end;

%subplot(1,2,1); hold on;
for i = 1 : size(inputsc1,1),
    cw = inputsc1(i,:);
    %plot(1:length(cw), cw, 'r*-');
    h1=plot(1:0.2:length(cw), spline(1:size(cw, 2), cw, 1:0.2:size(cw, 2)), 'r-');
end;
%ylim([0 150]); xlim([10 30]);

%subplot(1,2,2); hold on;
for i = 1 : size(inputsc2,1),
    cw = inputsc2(i,:);
    %plot(1:length(cw), cw, 'r*-');
    h2=plot(1:0.2:length(cw), spline(1:size(cw, 2), cw, 1:0.2:size(cw, 2)), 'g-');
end;
legend([h1,h2], {'Class 1','Class 2'});
%ylim([0 150]); xlim([10 30]);
h = xlabel('Time [ns]'); set(h, 'FontSize', 14);
h = ylabel('Intensity'); set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(7);
print(h, '-dpng', [project.result_folder '\wfs_' num2str(lb) '_' project.name '.png']);

% Plot the points by nn classes
class1 = find(outputs < lb);
class2 = find(outputs > ub);
points1 = sum_coors(class1, 1:3);
points2 = sum_coors(class2, 1:3);

figure(10);
clf; hold on;
plot3(points1(:,1), points1(:,2), points1(:,3), 'r*');
plot3(points2(:,1), points2(:,2), points2(:,3), 'g*');
xlabel('X'); xlabel('Y'); xlabel('Z');
grid on;
axis equal;




