%%
% General interface for selectin one dataset
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
function [dataset dataset_no]= select_dataset(project)
    fprintf('\n\nDatasets\n');
    fprintf('------------\n');
    corr = 0;
    fprintf('[0] Quit\n');
    while ~corr,
        for i = 1 : length(project.datasets),
            fprintf('[%i] %s\n', i, project.datasets{i}.name);
        end;
        result = input('Select one: ');

        if result == 0,
            dataset = 0;
            dataset_no = 0;
            return;
        end;
        
        if and( (result) > 0,  (result) <= length(project.datasets)),
            corr = 1;
            dataset_no = result;
            dataset = project.datasets{result};
        end;
    end;