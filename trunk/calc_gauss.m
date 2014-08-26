%%
% Caclulte the fitting Gussian function and store it in local variable
%
% Written by Zoltan Koppanyi
% Date: 07/24/2014
% The Ohio State Univeristy


%% Settings
%dataset_i = length(project.datasets);

dataset = project.datasets{dataset_i};


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
    waitbar(perc,h,sprintf('Calculate Gaussian fittings: %.1f%% Dataset: %s', perc*100, dataset.name));
    
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
    
    %% Impulse reponse
    ref = double(waveforms{i}.sbl{1}.sample);
    back = double(waveforms{i}.sbl{2}.sample);
    
    ref = spline(1:length(ref), ref, 1:0.25:length(ref));
    back = spline(1:length(back), back, 1:0.25:length(back));

    [mrv, mri] = max(ref);
    [mbv, mbi] = max(back);
    ref = [repmat(1, 1, mbi-mri), ref,  repmat(1, 1, length(back)-(mbi-mri)-length(ref))];
    
    % Checl that the length are same
    if length(ref) > length(back),
        disp('Reference wave is longer than back! Remove last digits!');
        ref = ref(1:length(back));
    end;

    if length(back) > length(ref),
        disp('The back wave is longer than reference! Remove last digits!');
        back = back(1:length(ref));
    end;

    ir = ref-back;
    waveforms{i}.impulse_response = ir(1:4:length(ir));
    
    % Gaussian for impulse response
    [val ind] = max(ir);
    tvalsir = linspace(min(tvals), max(tvals), length(ir));
    f = @(x) norm(ir - gaussfn(tvalsir, x));
    
    try
        xsol_ir = fminunc(f, [val, tvalsir(ind), 2, 0, 2]);
    catch
        try
            xsol_ir = fminunc(f, [1, 35, 2, 0, 2]);
        catch
            xsol_ir = xsol;
        end;
    end;    
    
    waveforms{i}.g_ir_samples = ir;
    waveforms{i}.g_ir_ts = tvalsir;
    waveforms{i}.g_ir_fn = gaussfn;
    waveforms{i}.g_ir_params = xsol_ir;
end;
close(h);

save(dataset.waveforms ,'waveforms');
