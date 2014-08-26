
dcoors = dcoors - repmat(mean(dcoors), size(dcoors, 1), 1);

% Run the classifiers
res_cmw = class_median_wf(cmw, dwfmx);
res_cdg = class_discr(cdg,  dgparam);
res_csom_grass = class_som(csom_grass, dwfmx);
res_csom = class_som(csom, dwfmx);

res_cmw.ratios(res_cmw.ratios == 0) = 0.1;
res_cdg.ratios(res_cdg.ratios == 0) = 0.1;
res_csom.ratios(res_csom.ratios == 0) = 0.1;
%res_csom.ratios = res_csom.ratios + 0.5;

plike = res_cmw.ratios .* res_cdg.ratios;
%plike = res_cmw.ratios;
%plike = res_csom.ratios;

plike = plike ./ sum(sum(plike)); % Normalizing
[val sol_class] = max(plike, [], 2);

% % Road 2 correction
idx = find(or(sol_class == 2, sol_class == 3));
%res_road2_corr = class_som(csom_grass, dwfmx(idx, :));
res_road2_corr = class_som(csom, dwfmx(idx, :));
[vals, ind_grass] = max(res_road2_corr.ratios(:,2:3), [], 2);
ind_grass(ind_grass == 1) = 100; ind_grass(ind_grass == 2) = 110;
ind_grass(ind_grass == 100) = 2; ind_grass(ind_grass == 110) = 3;
sol_class(idx) = ind_grass ;

% 
% Building correction
idx = find(or(sol_class == 1, sol_class == 5));
res_build_corr = class_som(csom, dwfmx(idx, :));
[~, ind] = max(res_build_corr.ratios(:,[1 5]), [], 2);
ind(ind == 1) = 1; ind(ind == 2) = 5;
sol_class(idx) = ind;


%% Check...

% Remove...
sel = 1 : length(val);
%sel = find(val > 2e-5 );

cfm = confusionmat(dclasses(sel), sol_class(sel))


% Save result
dlmwrite([project.result_folder '\class_' project.name '_cfm_' num2str(fig_num) '.csv'], cfm);

pos_false = zeros(size(cfm, 1), 1);
neg_false = zeros(size(cfm, 1), 1);
dlike = zeros(size(cfm, 1), 1);
for i = 1 : size(cfm, 1),
    pos_false(i) = 1 - cfm(i,i) ./ sum(cfm(i,:));
    neg_false(i) = 1 - cfm(i,i) ./ sum(cfm(:,i));
    dlike(i) = cfm(i,i) / (sum(cfm(i,:)) + sum(cfm(:,i)) - cfm(i,i));
end;


%% Show results

figure(fig_num ); clf; hold on;
rad = 3;

% Show result
subplot(1, 2, 1); hold on;
handles = [];
legend_labels = {};
for i = 1 : length(groups),
    idx = find(sol_class == i);
    h = plot(dcoors(idx, 1), dcoors(idx, 2), [colors(i), '.']);
    handles  = [handles, h];
    legend_labels{i} = groups{i}.name;
end;
legend(handles, legend_labels, 'FontSize', 14);
xlabel('X [m]', 'FontSize', 14);
ylabel('Y [m]', 'FontSize', 14);
set(gca, 'FontSize', 14);
title('Before filtering', 'FontSize', 14);
axis equal;
xlim([-60 60]); ylim([-60 60]);

% Filtering
sel = find(val > 0 );
dcoorsf = dcoors(sel, :);
dclassesf = dclasses(sel);
sol_class_f = sol_class(sel);

for i = 1 : size(dcoorsf, 1),
     diff = repmat(dcoorsf(i,1:3), size(dcoorsf, 1), 1) - dcoorsf(:,1:3);
     ind = find( sqrt( diff(:,1).^2 + diff(:,2).^2 + diff(:,3).^2 ) < rad );
     sol_class_f(i) = mode(sol_class(ind));
end;


% Display filtered cloud
subplot(1, 2, 2); hold on;
handles = [];
legend_labels = {};
for i = 1 : length(groups),
    idx = find(sol_class_f == i);
    h = plot(dcoorsf(idx, 1), dcoorsf(idx, 2), [colors(i), '.']);
    handles  = [handles, h];
    legend_labels{i} = groups{i}.name;
end;
legend(handles, legend_labels, 'FontSize', 14);
xlabel('X [m]', 'FontSize', 14);
ylabel('Y [m]', 'FontSize', 14);
set(gca, 'FontSize', 14);
title('After filtering', 'FontSize', 14);
axis equal;
xlim([-60 60]); ylim([-60 60]);


cfmf = confusionmat(dclassesf, sol_class_f)

% Save result
dlmwrite([project.result_folder '\class_' project.name '_cfmf_' num2str(fig_num) '.csv'], cfmf);

pos_falsef = zeros(size(cfmf, 1), 1);
neg_falsef = zeros(size(cfmf, 1), 1);
dlikef = zeros(size(cfmf, 1), 1);
for i = 1 : size(cfmf, 1),
    pos_falsef(i) = 1 - cfmf(i,i) ./ sum(cfmf(i,:));
    neg_falsef(i) = 1 - cfmf(i,i) ./ sum(cfmf(:,i));
    dlikef(i) = cfmf(i,i) / (sum(cfmf(i,:)) + sum(cfmf(:,i)) - cfmf(i,i));
end;

