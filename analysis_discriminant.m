

%% Gathering wavefroms into one matrix
sum_vals = [];
classes = [];
for i = 1 : length(groups),  
    if length(groups{i}.sk{wave_id}) == size(groups{i}.g_params{wave_id},1),
        val = [groups{i}.g_params{wave_id}, groups{i}.sk{wave_id}, groups{i}.skkurt{wave_id}];
    else
        disp(['g_params length does not match: ' groups{i}.name]);
        minidx = min(length(groups{i}.sk{wave_id}), size(groups{i}.g_params{wave_id}, 1));
        val = [groups{i}.g_params{wave_id}(1:minidx, :), groups{i}.sk{wave_id}(1:minidx, :), groups{i}.skkurt{wave_id}(1:minidx, :)];
    end;
    sum_vals = [sum_vals; val];   
    classes = [classes; repmat(i, size(val, 1), 1)];
end;

% Linear classifier
clfier = fitcdiscr(sum_vals, classes);

%Quadratic clssifier
%clfier = fitcdiscr(sum_vals, classes,...
%    'discrimType','quadratic');

pred_class = predict(clfier,sum_vals);
overall_rate = sum(pred_class == classes) / length(classes);
cmat = confusionmat(classes, pred_class);

% Save result
dlmwrite([project.result_folder '\anal_discr_' project.name '.csv'], cmat);

% Calculate positive falses and trues
false_positives = [];
false_negatives = [];
perc_fp = []; perc_fn = [];
for i = 1 : length(groups),
    false_negatives = [false_negatives; sum(cmat(i,:)) - cmat(i,i)];
    perc_fn = [perc_fn;  1-(cmat(i,i) / sum(cmat(i,:)) )];
    false_positives = [false_positives, sum(cmat(:,i)) - cmat(i,i)];
    perc_fp = [perc_fp,  1-(cmat(i,i) / sum(cmat(:,i)) )];
end;

oratio = sum(diag(cmat)) / sum(sum(cmat));         
cmat2 = [cmat,false_negatives; false_positives, sum([false_positives, false_negatives'])]
perc_fn
perc_fp



input('Press any key to continue...')