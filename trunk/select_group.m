function [group group_no] = select_group(project)
    result = input('Select the groups: ');
    if and( (result) > 0,  (result) <= length(project.groups) ),
        group_no = result;
        group = project.groups{result};
    else
        fprintf('Wrong number!\n')
    end;
