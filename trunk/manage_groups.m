%%
% Managing groups, add, delete modify groups
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Settings
clear all; clc; close all;

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
    fprintf(' Project: %s\n', project_file);
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
                if isfield(project.groups{i}, 'is_calc'),
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
	fprintf('\nProject:\n');
    fprintf('    [0]  Exit without saving\n')
    fprintf('    [1]  Exit with saving\n')
    fprintf('    [2]  Save\n')
    fprintf('    [3]  Calculate parameters\n')
    
    fprintf('\nGroups:\n');
    fprintf('    [4]  Create new group\n')
    fprintf('    [5]  Remove group\n')
    fprintf('    [6]  Add dataset to the group\n')
    fprintf('    [7]  Remove dataset from the group\n')
    fprintf('    [8]  Show classes\n')
    
    fprintf('\nClassifiers:\n');
    if g_nn ~= 0,
        fprintf('    Following options required to run 3 first!\n');
        fprintf('    (9)  Classifying by Gaussian parameters\n')
        fprintf('    (10) Classifying by skewness and kurtosis\n')
        fprintf('    (11) Classifying using neural network\n')
        fprintf('    (12) Classifying by Gaussian parameters using neural network\n');
        fprintf('    (13) Classfying by the distances from the median waveforms\n');
        fprintf('    (14) Discriminant analysis\n');
        fprintf('    (15) Clustering with SOM\n')
        fprintf('    (16) Combined clustering\n');
    else
        fprintf('    [9]  Classifying by Gaussian parameters\n')
        fprintf('    [10] Classifying by skewness and kurtosis\n')
        fprintf('    [11] Classifying using neural network\n')
        fprintf('    [12] Classifying by Gaussian parameters using neural network\n');
        fprintf('    [13] Classfying by the distances from the median waveforms\n');
        fprintf('    [14] Discriminant analysis\n');
        fprintf('    [15] Clustering with SOM\n')
        fprintf('    [16] Combined clustering\n')
    end


    % Select an option
    result = input('\nSelect option: ');
    if result == 0,
        return;
    end;

    % Execute commands
    if and( (result) > 0,  (result) <= 16),
        switch result
            
            % Exit with saving
            case 1,
                save(project_file, 'project');
                return;
                
            % Save
            case 2,
                save(project_file, 'project');
                continue;                

            % Calculate parameters
            case 3,
                for k1 = 1 : length(project.groups)
                    
                    answ = 'y';
                    if isfield(project.groups{k1}, 'is_gauss_fit'),
                        answ = input( ...
                            sprintf('The Gaussian parameters of the %s have been calcualted,\ndo you want to recalcualte them [y/n]? ', ...
                                project.groups{k1}.name), 's');
                    end;
                    
                    if strcmp(answ, 'y'),
                        for k2 = 1:length(project.groups{k1}.datasets),
                            dataset_i = project.groups{k1}.datasets(k2);
                            calc_gauss;
                        end;
                        project.groups{k1}.is_gauss_fit = 1;
                        save(project_file, 'project');
                        disp('Data has been saved!')
                    end;                   
                    
                end;
                
                groups = project.groups;
                calc_group_param;
                project.groups = groups;
                save(project_file, 'project');
                disp('Data has been saved!')
                continue;  
                
            % Create new group
            case 4,
                result = input('What will be the name of the new group: ', 's');
                 if(isfield(project, 'groups'))
                    project.groups{length(project.groups)+1}.name = result;
                    project.groups{length(project.groups)}.datasets = [];                     
                 else
                    project.groups{1}.name = result;
                    project.groups{1}.datasets = []; 
                 end;
                 
            % Create new group  
            case 5,
                [group group_no] = select_group(project);
                project.groups(group_no) = [];

            % Remove group
            case 6,
                [group group_no] = select_group(project);
                [dataset dataset_no]= select_dataset(project)
                if isnumeric(dataset),
                    continue;
                end;
                project.groups{group_no}.datasets = [...
                    project.groups{group_no}.datasets, dataset_no];
                
            % Remove dataset from the group
            case 7,
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
              
            % Show groups
            case 8,
                show_groups
 
            % Gaussian parameters
            case 9,
                groups = project.groups;
                analysis_gaussian;
                project.groups = groups;
                
            case 10,
                groups = project.groups;
                analysis_skewness;
                project.groups = groups;
                
                input('Press any key...');
                continue;
                
            case 11,
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
                
            case 12,
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
            
            case 13,
                groups = project.groups;
                analysis_median_waveform;
                
            case 14,
                groups = project.groups;
                analysis_discriminant;
                                
            case 15,
                groups = project.groups;
                analysis_som;
                
            case 16,
                groups = project.groups;
                analysis_beyasian;
        
            otherwise
                continue;
        end;
    end;
end;




