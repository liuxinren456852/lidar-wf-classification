function res = class_som(obj, wfmx)

    trans_waveform_fn = @(waveforms) trans_waveform(waveforms, -1);
    wfmx = trans_waveform_fn(wfmx);

    wfmx = wfmx(:, obj.from_digits:obj.to_digits);
    inputs  = wfmx';  
    outputs = obj.net(inputs);
    
    n = obj.dimensions(1)*obj.dimensions(2);
    group = zeros(1, size(wfmx, 1));
    classes = zeros(1, size(wfmx, 1));
    ratios = zeros(size(wfmx, 1), length(obj.uclasses));
    for i = 1 : n,
        ind = find(outputs(i,:)==1);
        group(ind) = i;
        
        [~, ci] = max(obj.cmat(i,:));
        classes(ind) = obj.uclasses(ci);

        ratios(ind,:) = repmat( obj.cmat(i,:) / sum(obj.cmat(i,:)), length(ind), 1);
    end;
        
    % Results
    res.classes = classes;
    res.ratios = ratios;

end
