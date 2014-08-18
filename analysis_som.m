

from_digits = 1;
to_digits = 60;

trans_waveform_fn = @(waveforms) trans_waveform(get_sample_to_mx( waveforms, 2 ), -1);
%trans_waveform_fn = @(waveforms) get_sample_to_mx( waveforms, 2 );

%% Gathering wavefroms into one matrix

group_no = input('Group for learning [use all]: ', 's');
use_all = 0;
if isempty(group_no),
    use_all = 1;
end;

if ~use_all, 
    group_no = str2num(group_no);

    % Load data
    sum_wfmx = [];  
    sum_coors = [];
    for j = 1:length(groups{group_no}.datasets),

            load( project.datasets{groups{group_no}.datasets(j)}.waveforms );
            add_wfmx = trans_waveform_fn(waveforms);
            sum_wfmx = [sum_wfmx; add_wfmx]; 

            load( project.datasets{groups{group_no}.datasets(j)}.coors );
            sum_coors = [sum_coors; coors];
    end;
    
else
    
    sum_wfmx = [];  
    sum_coors = [];
    classes = [];
    for i = 1 : length(groups),   
        disp(['Loading: ' groups{i}.name]);
        wfmx = [];  
        
        for j = 1:length(groups{i}.datasets)
            load( project.datasets{groups{i}.datasets(j)}.waveforms );
            %wfmx = [wfmx; get_sample_to_mx( waveforms, 2 )];

            add_wfmx = trans_waveform(get_sample_to_mx( waveforms, 2 ), -1);
            wfmx = [wfmx; add_wfmx];

            load( project.datasets{groups{i}.datasets(j)}.coors );
            sum_coors = [sum_coors; coors];
            
            classes = [classes; repmat(i, size(coors, 1), 1)];
        end;

        sum_wfmx = [sum_wfmx; wfmx];   
    end;
end;

% Check that the dimesnions are same
if and(size(sum_wfmx, 1) ~= size(sum_coors, 1), size(sum_coors, 1) ~= length(classes)),
    disp('The waveform and coordinate matrix dimensions are not same!');
    input('Press enter...', 's');
    return;
end;

% Reduce point set
select_ind = 1:1:size(sum_wfmx, 1);
wfmx_exam = sum_wfmx(select_ind,from_digits:to_digits);
coors_exam = sum_coors(select_ind,:);
classes_exam = classes(select_ind);

inputs  = wfmx_exam';    

% Create a Self-Organizing Map
dimension1 = 3;
dimension2 = 3;
net = selforgmap([dimension1 dimension2]);

% Train the Network
[net,tr] = train(net,inputs);

% Test the Network
outputs = net(inputs);

%% Display results
figure(1); clf; hold on;
figure(2); clf; hold on;
figure(3); clf; hold on;

% Transform coors
if ~use_all,
    coors_orig = coors_exam(:,1:3) - repmat(mean(coors_exam(:,1:3)), size(coors_exam, 1), 1);
    [S V D] = svd(coors_orig);
    coors_trans = (D'*coors_exam(:,1:3)')';
    coors_trans = coors_trans - repmat(mean(coors_trans), size(coors_trans, 1), 1);
else
    coors_trans = coors_exam(:,1:3) - repmat(mean(coors_exam(:,1:3)), size(coors_exam, 1), 1);
end;

% Displaying
colors = jet((dimension1*dimension2));
legend_handles_1 = [];
legend_handles_2 = [];
legend_labels = {};
for i = 1 : (dimension1*dimension2),
    ind = find(outputs(i,:)==1);

    % Put waveform
    figure(1);
    subplot(dimension1, dimension2, i); hold on;
    for j = 1 : length(ind),
        h=plot(1:length(wfmx_exam(j,:)), wfmx_exam(j,:), 'k-', 'Color', colors(i, :));
    end;
    legend_handles_1 = [legend_handles_1, h]; legend_labels{i} = ['Group ' num2str(i)];
    xlabel('Normalized samples [ns]', 'FontSize', 14);
    ylabel('Intensity [-]', 'FontSize', 14);
    title(['Group ' num2str(i)], 'FontSize', 14);
    
    % Put point
    figure(2);
    plot3(coors_trans(ind,1), coors_trans(ind,2), coors_trans(ind,3), 'k.', 'Color', colors(i, :));    
    
    offs_x = 20;
    offs_y = 10;
    
%     % Y Cross section
%      [bins xval] = hist(coors_trans(ind,1), 50);
%      bins = bins ./ 100 * 20;
%      h=plot3(xval, repmat(min(coors_trans(:,2)), 1, length(xval)) - offs_y + bins, repmat(0, length(xval), 1), 'k-', 'Color', colors(i, :), 'LineWidth', 2);
%      plot3(xval, repmat(min(coors_trans(:,2)), 1, length(xval)) - offs_y, repmat(0, length(xval), 1), 'k--', 'LineWidth', 2);
%      legend_handles_2=[legend_handles_2; h]; legend_labels{i} = ['Group ' num2str(i)];
    
%     % X cross-section
%     [bins xval] = hist(coors_trans(ind,2), 100);
%     bins = bins ./ 100 *  10;
%     h = plot3(repmat(min(coors_trans(:,1)), 1, length(xval)) - offs_x + bins, xval, repmat(0, length(xval), 1), 'k-', 'Color', colors(i, :), 'LineWidth', 2);
%     %legend_handles_2=[legend_handles_2; h]; legend_labels{i} = ['Group ' num2str(i)];
%     plot3(repmat(min(coors_trans(:,1)), 1, length(xval)) - offs_x, xval, repmat(0, length(xval), 1), 'k--', 'LineWidth', 2);
    
    xlabel('X [m]', 'FontSize', 14); ylabel('Y [m]', 'FontSize', 14);
    set(gca, 'FontSize', 14);
    axis equal;
    grid on;
    
    figure(3);
    %scatter3(coors_exam(ind,1), coors_exam(ind,2), coors_exam(ind,3), 10, max(wfmx_exam(ind,:), [], 2) );
    %scatter3(coors_exam(ind,1), coors_exam(ind,2), coors_exam(ind,3), 5, coors_exam(ind,3) );
    scatter3(coors_exam(ind,1), coors_exam(ind,2), coors_exam(ind,3), 10, coors_exam(ind,7) );
    
    %z = (abs(coors_exam(ind,7))/max(abs(coors_exam(:,7)))) .* (coors_exam(ind,3)/max(coors_exam(:,3)));
    %scatter3(coors_exam(ind,1), coors_exam(ind,2), coors_exam(ind,3), 10,  z);
    axis equal;
    colorbar;
    grid on;
    
end;

figure(1);
legend(legend_handles_1, legend_labels, 'FontSize', 14);
set(gca, 'FontSize', 14 )

figure(2);
legend(legend_handles_2, legend_labels, 'FontSize', 14);


%% Plot  weights
weights = net.IW{1};
[val ind] = sort(net.IW{1}, 2);

legend_handles = [];
legend_labels = {};
figure(5); clf; hold on;
for i = 1: size(weights, 1),
    h = plot(1:size(weights, 2), weights(i, :), 'k-', 'Color', colors(i, :), 'LineWidth', 2);    
    legend_handles = [legend_handles, h]; legend_labels{i} = ['Group ' num2str(i)];
end;
legend(legend_handles, legend_labels, 'FontSize', 14); 
set(gca, 'FontSize', 14);
xlabel('Sample #', 'FontSize', 14); ylabel('Weight [-]', 'FontSize', 14);

%% Validation
if ~use_all,
    
    group_no = input('Group for testing: ', 's');
    group_no = str2num(group_no);

    % Load data
    sum_wfmx = [];  
    sum_coors = [];
    for j = 1:length(groups{group_no}.datasets),

            load( project.datasets{groups{group_no}.datasets(j)}.waveforms );
            add_wfmx = trans_waveform_fn(waveforms);
            sum_wfmx = [sum_wfmx; add_wfmx]; 

            load( project.datasets{groups{group_no}.datasets(j)}.coors );
            sum_coors = [sum_coors; coors];
    end;

    % Reduce dataset
    select_ind = 1:1:size(sum_wfmx, 1);
    wfmx_exam = sum_wfmx(select_ind,:);
    coors_exam = sum_coors(select_ind,:);

    % Check that the dimesnions are same
    if size(wfmx_exam, 1) ~= size(coors_exam, 1),
        disp('The waveform and coordinate matrix dimensions are not same!');
        input('Press enter...', 's');
        return;
    end;

    % Run Network
    inputs  = wfmx_exam';  
    outputs = net(inputs);

    % Display validation
    figure(6); clf; hold on;
    for i = 1 : (dimension1*dimension2),

        % Select points within the group
        ind = find(outputs(i,:)==1);

        % Put point
        plot3(sum_coors(ind,1), sum_coors(ind,2), sum_coors(ind,3), 'k.', 'Color', colors(i, :));  
    end;
    xlabel('X [m]', 'FontSize', 14); ylabel('Y [m]', 'FontSize', 14); zlabel('Z [m]', 'FontSize', 14);
    title('Validation', 'FontSize', 14);
    axis equal; grid on;
    set(gca, 'FontSize', 14);
    
else
    nums = zeros(dimension1*dimension2, length(groups));
    nums_perc = zeros(dimension1*dimension2, length(groups));
    for i = 1 : (dimension1*dimension2),
        ind = find(outputs(i,:)==1);

        class_inside = classes(ind);
        for j = 1 : length(groups),
            num_elems = sum(class_inside == j);
            nums(i,j) = num_elems;
            nums_perc(i,j) = num_elems/length(class_inside);
            fprintf('Group %i; %s; %i; %.1f%% \n', i, groups{j}.name, num_elems, num_elems/length(class_inside)*100 );
        end;
            
        % Save result
        dlmwrite([project.result_folder '\som_classes_' project.name '.csv'], nums_perc);
        
    end;

end;





