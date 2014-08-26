%%
% Neural network with the gaussian parameters
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Neural network
ub = 1-lb;

sum_samples = [];
for i = 1 : length(groups),
   g_params = groups{i}.g_params{wave_id};
   skkurt = [groups{i}.sk{wave_id} groups{i}.skkurt{wave_id}];
   sum_samples = [sum_samples; repmat(i-1, size(g_params, 1), 1), [g_params skkurt]];
end;

inputs = sum_samples(:,2:end)';
targets = sum_samples(:,1)';

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

%% Displaying
figure(8); clf; hold on;
indf = find(or(outputs < lb, outputs > ub));
targetsc = targets(indf); outputsc = outputs(indf);
plotconfusion(targetsc,outputsc)
h=title('Overall');set(h, 'FontSize', 14);
set(gca, 'FontSize', 14);
h=figure(8);
print(h, '-dpng', [project.result_folder '\gauss_cm_over_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\gauss_cm_train_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\gauss_cm_valid_' num2str(lb) '_' project.name '.png']);

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
print(h, '-dpng', [project.result_folder '\gauss_cm_test_' num2str(lb) '_' project.name '.png']);

fprintf('Bound: %.1f\nNo. of points: %i\nNo. of selected points: %i (%.1f%%)\n', lb, length(outputs), length(indf), length(indf)/length(outputs)*100);

h=figure(12); clf; hold on;
hist(outputs,20);
