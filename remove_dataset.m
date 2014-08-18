%%
% Remove a dataset from the project
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%%
settings;
load(project_file);

fprintf('\n\nDatasets\n');
fprintf('------------\n');
corr = 0;
while ~corr,
        for i = 1 : length(project.datasets),
            fprintf('[%i] %s\n', i, project.datasets{i}.name);
        end;
        result = input('Which one do you want to remove: ');

        if and( (result) > 0,  (result) <= length(project.datasets)),
            corr = 1;
            project.datasets(result) = []
        end;
end;

save(project_file, 'project');


    
    