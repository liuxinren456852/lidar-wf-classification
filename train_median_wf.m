function obj = train_median_wf(classes, wfmx)

    from_digits = 10;
    to_digits = 40;
    data_ratio_rate = 1;
    
    obj = {};
    obj.from_digits = from_digits;
    obj.to_digits = to_digits;
    obj.data_ratio_rate = data_ratio_rate;
    
    uclasses = unique(classes);
    obj.uclasses = uclasses;


    % Determine median classes
    for i = 1 : length(uclasses),

        idx = find(classes == i);
        obj.median_wf{i} = median(wfmx(idx, from_digits:to_digits));
        
    end;
    
    % Create confusion matrix
    for i = 1 : length(uclasses),

        % Reference waveform
        mwf = obj.median_wf{i};

        % Calculate waveform distances
        diff_wf = wfmx(:,from_digits:to_digits) - repmat(mwf, size(wfmx, 1), 1);

        % Measuring calculate distance
        class_vals(:,i) = max(abs(diff_wf), [], 2);
        
    end;

    % Get chossen classes
    [val, ind] = min(class_vals, [], 2);

    % Select...
    sel = find( val < ( mean(val) * data_ratio_rate ) );

    % Confusion matrix
    cmat = confusionmat(classes(sel), ind(sel));
    dcmat = diag(cmat);
    pcmat = cmat;
    for i = 1 : length(dcmat),
        dcmat(i) = dcmat(i) / (sum(cmat(i,:)) + sum(cmat(:,i)) - cmat(i,i) );
        pcmat(:,i) = pcmat(:,i) ./ sum(pcmat(:,i));
        %pcmat(i,:) = pcmat(i,:) ./ sum(pcmat(i, :));
    end;

    obj.cmat = cmat;
    obj.dcmat = dcmat;
    obj.pcmat = pcmat';

end

