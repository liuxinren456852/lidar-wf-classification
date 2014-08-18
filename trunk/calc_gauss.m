%%
% Caclulte the fitting Gussian function and store it in local variable
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy


%% Settings
dataset = project.datasets{length(project.datasets)};


%% Loading
load(dataset.coors);
load(dataset.waveforms);
load(dataset.sdf_info);

%% Processing
%figure(1); clf; hold on;
h = waitbar(0, 'Calculate Gaussian fittings...');
for i = 1 : length(waveforms),
%for i = 50 : 150,
    
    perc = i/length(waveforms);
    waitbar(perc,h,sprintf('Calculate Gaussian fittings: %.1f%% ',perc*100));
    
    if length(waveforms{i}.sbl) < 2,
        continue;
    end;
    
    sbl = waveforms{i}.sbl{2};

    samples = double(sbl.sample);
    tstart = sbl.time_sosbl;
    stime = double(sdf_info.sampling_time);
    ts = tstart : stime : (tstart+(length(samples)-1)*stime);


    %% Fitting gaussian
    tvals = (ts-ts(1))*10^9;
    [val ind] = max(samples);

    %gaussfn = @(x, p) p(1)*exp( -(x-p(2)).^2/(2*p(3).^2) ) + p(4);
    gaussfn = @(x, p) p(1) * exp( - ( (x-p(2)) / p(3) ) .^ p(5) ) + p(4);
    f = @(x) norm(samples - gaussfn(tvals, x));
    xsol = fminunc(f, [val, tvals(ind), 2, 0, 2]);

    %[f, p] = leasqr(tvals, samples, [tvals(ind), val, 1, 10.0, 0.0, 0], 'param_gauss_wf',.0002); 

    %% Plotting
    %plot(tvals ,samples, 'r*-');
    %tsol = min(tvals):0.1:max(tvals);
    %plot(tsol , gaussfn(tsol , xsol), 'b-');
    
    % Put parameters into variables
    waveforms{i}.g_samples = samples;
    waveforms{i}.g_ts = tvals;
    waveforms{i}.g_fn = gaussfn;
    waveforms{i}.g_params = xsol;
end;
close(h);

save([project.result_folder '\' dataset.name '_waveforms'] ,'waveforms');
