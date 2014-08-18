
%% Settings
valid_set_ratio = 0.3;
train_set_ratio = 1 - valid_set_ratio;

%% Gathering waveforms points and others into matrices
swfmx = [];
train_wfmx = [];
valid_wfmx = [];

scoors = [];
train_coors = [];
valid_coors = [];

classes = [];
train_classes = [];
valid_classes = [];

sgparam = [];
train_gparam = [];
valid_gparam = [];

for i = 1 : length(groups),   
    
    fprintf('Group: %s\n', groups{i}.name);
    
    wfmx = groups{i}.wfmx;
    load(project.datasets{groups{i}.datasets}.coors);
    
    if length(groups{i}.sk) == size(groups{i}.g_params,1),
        gparams = [groups{i}.g_params, groups{i}.sk, groups{i}.skkurt];
    else
        disp(['g_params length does not match: ' groups{i}.name]);
        gparams = [groups{i}.g_params(1:length(groups{i}.sk), :), groups{i}.sk, groups{i}.skkurt];
    end;
       
    % Checking coors and wfmx matrices size
    if or(size(wfmx, 1) ~= size(coors, 1), size(wfmx, 1) ~= size(gparams, 1)), 
        disp('Waveforms and coordinate matrix are not same size!')
        size(wfmx, 1)
        size(coors, 1)
        size(gparams, 1)
        input('Press any key...');
        %return;
    end;
    
    % Sum
    wfmx_add = trans_waveform(wfmx, -1);
    
    % Normalizing 
%     for k = 1 : size(wfmx_add, 1),
%         wfmx_add(k,:) = wfmx_add(k,:) / max(wfmx_add(k,:));
%     end;
    
    swfmx = [swfmx; wfmx];
    classes = [classes; repmat(i, size(wfmx, 1), 1)];       
    scoors = [scoors; coors];
    sgparam = [sgparam; gparams];
    
    % Train set
    idxt = round(1:(1/train_set_ratio):size(wfmx_add, 1));    
    train_wfmx = [train_wfmx; wfmx_add(idxt, :)];
    train_classes = [train_classes; repmat(i, length(idxt), 1)];
    train_coors = [train_coors; coors(idxt, :)];
    train_gparam = [train_gparam; gparams(idxt, :)];
    
    % Valid set
    idxv = setdiff(1:size(wfmx_add, 1), idxt);
    valid_wfmx = [valid_wfmx; wfmx_add(idxv, :)];
    valid_classes = [valid_classes; repmat(i, length(idxv), 1)];
    valid_coors = [valid_coors; coors(idxv, :)];
    valid_gparam = [valid_gparam; gparams(idxv, :)];
       
end;

% Checking sizes
chk = [size(train_wfmx, 1) + size(valid_wfmx, 1) == size(swfmx, 1), ...
       length(train_classes) + length(valid_classes) == length(classes), ...
       size(train_coors, 1) + size(valid_coors, 1) == size(scoors, 1), ...
       size(train_gparam, 1) + size(valid_gparam, 1) == size(sgparam, 1)];
   
if sum(~chk) ~= 0,
    disp('Problem with the matrix dimensions');
    chk
    input('Press enter...');
    %return;
end;

%% Median waveform - Train

cmw = train_median_wf(train_classes, train_wfmx);
res_cmw = class_median_wf(cmw, train_wfmx);

% Check train
chk_cmw = confusionmat(train_classes(res_cmw.selected), res_cmw.classes(res_cmw.selected));
if chk_cmw ~= cmw.cmat,
    disp('Check failed 1!'); input('Press enter to continue...');
    return;
end;
    
%% Discriminant - Train
cdg = train_discr(train_classes, train_gparam);
res_cdg = class_discr(cdg,  train_gparam);

% Check train
chk_cdg = confusionmat(train_classes, res_cdg.classes);
if chk_cdg ~= cdg.cmat,
    disp('Check failed 2!'); input('Press enter to continue...');
    return;
end;

%% SOM
csom_grass = train_som(train_classes, train_wfmx, [2 2]);
res_csom_grass = class_som(csom_grass, train_wfmx);
chk_csom = confusionmat(train_classes, res_csom_grass.classes);
csom_grass.pcmat;

csom = train_som(train_classes, train_wfmx, [3 3]);
res_csom = class_som(csom_grass, train_wfmx);
chk_csom = confusionmat(train_classes, res_csom.classes);
csom.pcmat


%% Decisions
dwfmx = train_wfmx;
dclasses = train_classes;
dcoors = train_coors;
dgparam = train_gparam;
fig_num = 1;
decision

dwfmx = valid_wfmx;
dclasses = valid_classes;
dcoors = valid_coors;
dgparam = valid_gparam;
fig_num = 2;
decision

