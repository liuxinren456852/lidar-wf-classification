%%
% Display classes
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Display dataset
h1=figure(1); clf; hold on;
for i = 1 : length(project.groups),
    for j = 1 : length(project.groups{i}.datasets)
        dataset = project.datasets{project.groups{i}.datasets(j)};
        load(dataset.coors);
        h(i) = plot3(coors(:,1), coors(:,2), coors(:,3), [colors(i), '*']);
        h_name{i} = project.groups{i}.name;
    end
end
grid on;
h=legend(h, h_name);
set(h, 'FontSize', 14);
h=xlabel('X [m]'); set(h, 'FontSize', 14);
h=ylabel('Y [m]'); set(h, 'FontSize', 14);
h=zlabel('Z [m]');set(h, 'FontSize', 14);

set(gca, 'FontSize', 10);
axis equal;

saveas(h1, [project.result_folder '\' project.name '_display.png'],'png');
disp(['Figure saved: ', project.result_folder '\' project.name '_display.png']);