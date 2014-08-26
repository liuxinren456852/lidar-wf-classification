function ret = get_gaussian_param_to_mx( wf, is_ir )

    % Create matrix from the gaussian parameters in the waveform structure
    ret = zeros(length(wf), length(wf{1}.g_params));
    for i = 1 : length(wf),
        if isfield(wf{i}, 'g_params'),
            if ~is_ir,
                ret(i, :) = wf{i}.g_params(:);
            else
                ret(i, :) = wf{i}.g_ir_params(:);
            end;
        else
            fprintf('No g_params in %ith waveforms!\n', i);
        end;
    end;

end

