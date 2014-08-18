function res = class_median_wf(obj,  wfmx)

    % Create confusion matrix
    for i = 1 : length(obj.uclasses),

        % Reference waveform
        mwf = obj.median_wf{i};

        % Calculate waveform distances
        diff_wf = wfmx(:,obj.from_digits:obj.to_digits) - repmat(mwf, size(wfmx, 1), 1);

        % Measuring calculate distance
        class_vals(:,i) = max(abs(diff_wf), [], 2);
        
    end;
    
    % Get chosen classes
    [val, ind] = min(class_vals, [], 2);

    % Select...
    sel = find( val < ( mean(val) * obj.data_ratio_rate ) );

    % Calculate ratios
    res.selected = sel;
    res.classes = obj.uclasses(ind);
    res.ratios = obj.pcmat(ind, :);
    res.val = val;
    
end

