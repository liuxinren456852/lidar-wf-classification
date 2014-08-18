%%
% Managing groups, add, delete modify groups
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Settings
clear all; clc;

settings;
load(project_file); 

colors = 'rgbcyk';

%% Menu
corr = 0;
while ~corr,
    
    % Show groups
    clc;
    fprintf(' Manage groups\n');
    fprintf(' ----------------------\n')
    
    g_nn = 0;
    if (isfield(project, 'groups'))
        if length(project.groups) > 0,
            for i = 1 : length(project.groups)
                fprintf('[%i] %s\n', i, project.groups{i}.name);
                for j = 1 : length(project.groups{i}.datasets),
                    fprintf('        [%i] %s\n', j, project.datasets{project.groups{i}.datasets(j)}.name);
                end;
                
                % Check g_params field exist
                if isfield(project.groups{i}, 'g_params'),
                    g_nn = g_nn+1;
                end;
                
            end;
            
            g_nn = g_nn - length(project.groups);
        else
            fprintf('\nNo groups.\n');
        end;
    else
        fprintf('\nNo groups.\n');
    end;

    % Menu
	fprintf('\n');
    fprintf('    [0]  Exit without saving\n')
    fprintf('    [1]  Exit with saving\n')
    fprintf('    [2]  Create new group\n')
    fprintf('    [3]  Remove group\n')
    fprintf('    [4]  Add dataset to the group\n')
    fprintf('    [5]  Remove dataset from the group\n')
    fprintf('    [6]  Show groups\n')
    fprintf('    [7]  Classifying by Gaussian parameters\n')
    fprintf('    [8]  Classifying by skewness and kurtosis\n')
    fprintf('    [9]  Classifying using neural network\n')
    if g_nn ~= 0,
        fprintf('    (10) Classifying by Gaussian parameters using neural network (run 7 first!)\n');
        fprintf('    (11) Classfying by the distances from the median waveforms (run 7 first!)\n');
        fprintf('    (12) Discriminant analysis\n (run 7 and 8 first!)');
    else
        fprintf('    [10] Classifying by Gaussian parameters using neural network\n');
        fprintf('    [11] Classfying by the distances from the median waveforms\n');
        fprintf('    [12] Discriminant analysis\n');
    end
    fprintf('    [13] Clustering with SOM\n')
    fprintf('    [14] Beyasian clustering\n')

    % Select an option
    result = input('\nSelect option: ');
    if result == 0,
        return;
    end;

    % Execute commands
    if and( (result) > 0,  (result) <= 15),
        switch result
            
            % Exit without saving
            case 1,
                save(project_file, 'project');
                return;
                
            % Exit with saving
            case 2,
                result = input('What will be the name of the new group: ', 's');
                 if(isfield(project, 'groups'))
                    project.groups{length(project.groups)+1}.name = result;
                    project.groups{length(project.groups)}.datasets = [];                     
                 else
                    project.groups{1}.name = result;
                    project.groups{1}.datasets = []; 
                 end;
                 
            % Create new group  
            case 3,
                [group group_no] = select_group(project);
                project.groups(group_no) = [];

            % Remove group
            case 4,
                [group group_no] = select_group(project);
                [dataset dataset_no]= select_dataset(project)
                if isnumeric(dataset),
                    continue;
                end;
                project.groups{group_no}.datasets = [...
                    project.groups{group_no}.datasets, dataset_no];
                
            case 5,
                [group group_no] = select_group(project);
                for j = 1 : length(project.groups{group_no}.datasets),
                    fprintf('        [%i] %s\n', j, project.datasets{project.groups{group_no}.datasets(j)}.name);
                end;
                result = input('Which dataset do you want to remove: ');
                if and( (result) > 0,  (result) <= length(project.groups{group_no}.datasets)),
                    project.groups{group_no}.datasets(result) = [];
                else
                    fprintf('\nWrong dataset no.\n');
                end;
                
            case 6,
                show_groups
                
            case 7,
                groups = project.groups;
                analysis_gaussian;
                project.groups = groups;
                
            case 8,
                groups = project.groups;
                analysis_skewness;
                project.groups = groups;
                
                input('Press any key...');
                continue;
                
            case 9,
                result = input('Lower bound (0-0.5): ');
                if and( (result) > 0,  (result) <= 0.5),
                    lb = result;
                    groups = project.groups;
                    analysis_neural_network;
                    input('Press any key...');
                    close all;
                else
                    fprintf('\nWrong upper bound!\n');
                    continue;
                end;
                
            case 10,
                if g_nn == 0,
                    result = input('Lower bound (0-0.5): ');
                    if and( (result) > 0,  (result) <= 0.5),
                        lb = result;
                        groups = project.groups;
                        analysis_nn_with_gussian_params;
                        input('Press any key...');
                        close all;
                    else
                        fprintf('\nWrong upper bound!\n');
                        continue;
                    end;
                else
                    disp('Run first [7]');
                    input('Press any key...');
                    continue;
                end;
            
            case 11,
                groups = project.groups;
                analysis_median_waveform;
                
            case 12,
                groups = project.groups;
                analysis_discriminant;
                                
            case 13,
                groups = project.groups;
                analysis_som;
                
            case 14,
                groups = project.groups;
                analysis_beyasian;
        
            otherwise
                continue;
        end;
    end;
end;




