%%
% Group analysis of skewness and kurtosis 
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy

%% Skewness and kurtosis

figure(5); clf; hold on;
figure(6); clf; hold on;
colors = 'rgbcyk';
sumkurt = [];

% Get waveforms
for i = 1 : length(groups),
    groups{i}.wfmx = [];
    for j = 1:length(groups{i}.datasets)
        load( project.datasets{groups{i}.datasets(j)}.waveforms );
        groups{i}.wfmx = [groups{i}.wfmx; get_sample_to_mx( waveforms, 2 )];
    end;
end;

s = 'Dataset #; Mean skewness; Median skewness; Mean kurtosis; Median kurtosis\n';
for gi = 1 : length(groups)
    
    % Calcualte kurtosis and skewness
    skl = skewness(groups{gi}.wfmx(:, 1:40), 1, 2);
    kurtl = kurtosis(groups{gi}.wfmx(:, 1:40), 1, 2);
    
    % Calcualte mean
    mskl = mean(skl); sskl = std(skl);
    mkurtl = mean(kurtl); skurtl = std(kurtl);

    % Calcualte standard deviation
    %skl = skl(and((mskl-sskl)<skl, skl<(mskl+sskl)));
    %kurtl = kurtl(and((mkurtl-skurtl)<kurtl, kurtl<(mkurtl+skurtl)));
    
    % Save to local variables
    groups{gi}.sk = skl;
    groups{gi}.skkurt = kurtl;
    
    sumkurt = [sumkurt; repmat(gi, length(kurtl), 1), kurtl];
    
    % Display skewness
    h1=figure(5);
    subplot(1,length(groups),gi); hold on;
    hist(skl, 100);
    [bins, binx] = hist(skl, 100);
    title(['Skewness - ' groups{gi}.name])
    h=plot([mean(skl), mean(skl)], [0 max(bins)], 'r-');
    set(h, 'LineWidth', 2);
    h=plot([median(skl), median(skl)], [0 max(bins)], 'g-');
    set(h, 'LineWidth', 2);
    xlabel('Value [ns]'); ylabel('Freq [-]');
    %xlim([3 3.2])
    xlim([mean(skl)-3*std(skl) mean(skl)+3*std(skl)])
    
    % Display kurtosis
    h2=figure(6);
    subplot(1,length(groups),gi); hold on;
    hist(kurtl, 100);
    [bins, binx] = hist(kurtl, 100);
    title(['Kurtosis - ' groups{gi}.name])
    h=plot([mean(kurtl), mean(kurtl)], [0 max(bins)], 'r-');
    set(h, 'LineWidth', 2);
    h=plot([median(kurtl), median(kurtl)], [0 max(bins)], 'g-');
    set(h, 'LineWidth', 2);
    xlabel('Value [ns]'); ylabel('Freq [-]');
    xlim([mean(kurtl)-3*std(kurtl) mean(kurtl)+3*std(kurtl)])
    
    s = [s, sprintf('Dataset %i, %.3f, %.3f, %.3f, %.3f\n', gi, mean(skl), median(skl), mean(kurtl), median(kurtl))];

end;
fprintf(s);

% Save the figures
saveas(h2, [project.result_folder '\' project.name '_kurt_hist.png'],'png');
saveas(h1, [project.result_folder '\' project.name '_skew_hist.png'],'png');

% Save the text
fid = fopen([project.result_folder '\' project.name '_kurt.txt'],'w');            
fprintf(fid,'%s\r\n',s);       
fclose(fid);