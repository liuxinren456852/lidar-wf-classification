clear all; clc;

sample_num = 300;
error_std = 1.5;

%% Reference waves
a = 31.0;
b = 16.0;
c = 1.88;
d = 2.22;
e = 2;

x = 0:0.1:40;

gaussfn = @(x, p) p(1)*exp( - ( (x-p(2)) / p(3) ) .^ p(5) ) + p(4);

figure(1); clf; hold on;
subplot(2,1,1); hold on;
h1=plot(x, gaussfn(x, [a b c d e]), 'r-');
set(h1, 'LineWidth', 2);
ref1 = gaussfn(0:39, [a b c d e]);
plot((1:length(ref1))-1, ref1, 'r*');

h2=plot(x, gaussfn(x, [a b+0.2 c+0.2 d e]), 'g-');
set(h2, 'LineWidth', 2);
ref2 = gaussfn(0:39, [a b+0.2 c+0.2 d e]);
plot((1:length(ref2))-1, ref2, 'g*');
legend([h1 h2], {'Ref1', 'Ref2'});

h=xlabel('Time [ns]'); set(h,'FontSize', 14);
h=ylabel('Intensity'); set(h,'FontSize', 14);
set(gca,'FontSize', 14);


%% Generate samples
subplot(2,1,2); hold on;

samples1 = zeros(sample_num, length(ref1));
for i = 1:sample_num,
    
    % Apply translation
    offs = round(rand*8-4);
    ref1t = ref1;
    if offs > 0,
        ref1t = [ref1(offs:end) repmat(ref1(end), 1, offs-1)];
    end;
    if offs < 0,
        ref1t = [repmat(ref1(1), 1, abs(offs)), ref1(1:(end-abs(offs)))];
    end;
    
    % Put noise
    samples1(i,:) = normrnd(ref1t, error_std);
    %samples1(i,:) = trans_waveform(samples1(i,:), -1);
    h1=plot((1:length(samples1(i,:)))-1, samples1(i,:), 'r-');
end;

samples2 = zeros(sample_num, length(ref2));
for i = 1:sample_num,
    
    % Apply translation
    offs = round(rand*4)+1;
    ref2t = [ref2(offs:end) repmat(ref2(end), 1, offs-1)];
    
    % Put noise
    samples2(i,:) = normrnd(ref2t, error_std);
    %samples2(i,:) = trans_waveform(samples2(i,:), -1);
    h2=plot((1:length(samples2(i,:)))-1, samples2(i,:), 'g-');
end;

legend([h1 h2], {'Sample1', 'Sample2'});
h=xlabel('Time [ns]'); set(h,'FontSize', 14);
h=ylabel('Intensity'); set(h,'FontSize', 14);
set(gca,'FontSize', 14);

%%
nn_results = 'nn_results';
run_name = 'proof';

% Translate the waveform
%samples1 = trans_waveform(samples1, -1);
%samples2 = trans_waveform(samples2, -1);

% Data manipulation for neural network
sum_samples=[repmat(1,size(samples1, 1), 1) samples1; repmat(2,size(samples2, 1), 1), samples2];
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

lb = 0.5; ub = 1-lb;

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

