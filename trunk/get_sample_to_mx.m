function ret = get_sample_to_mx( wf, channel, is_ir )

    % Create matrix from the sampels in the waveform structure
    
    sample_n = length(wf{1}.sbl{2}.sample);
    ret = zeros(length(wf), sample_n);
    for i = 1:length(wf),
        
        % Calculate difference
        % diff = [0, waveformsl{gi}{i}.sbl{2}.sample(2:end) - waveformsl{gi}{i}.sbl{2}.sample(1:(end-1))];
        % diff = cumsum(waveformsl{gi}{i}.sbl{2}.sample);
        % mwaveforms{gi}(i,:) = diff;
        
        % Check that channel is available
        if length(wf{i}.sbl) < channel,
            fprintf('No channel %i!\n', channel);
            continue;
        end;
        
        if size(wf{i}.sbl{channel}.sample, 2) ~= 60,
            fprintf('Problem with sample size: %i\n', size(wf{i}.sbl{channel}.sample, 2));
            ret(i,:) = wf{i}.sbl{channel}.sample(1:60);
            continue
        end;
        
        % Trnsform emitted waveforms
%         ref = wf{i}.sbl{1}.sample;
%         back = wf{i}.sbl{2}.sample;
%         [mrv, mri] = max(ref);
%         [mbv, mbi] = max(back);
%         refs = [repmat(1, 1, mbi-mri), ref,  repmat(1, 1, 60-(mbi-mri)-length(ref))];
%         refs = refs(1:60);
%         ret(i,:) = refs-back;

        if ~is_ir,
            ret(i,:) = wf{i}.sbl{channel}.sample;
        else
            ret(i,:) = wf{i}.impulse_response;
        end;
    end;
    
    % Clean up mx
    ind = find(sum(ret,2)==0);
    ret(ind,:) = [];

end

