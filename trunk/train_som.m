function obj = train_som(classes, wfmx, dimensions)

    trans_waveform_fn = @(waveforms) trans_waveform(waveforms, -1);

    wfmx = trans_waveform_fn(wfmx);
    
    from_digits = 1;
    to_digits = 60;

    % Classes
    uclasses = unique(classes);

    % Topology
    %dimensions = [2 2];
    
    % Save fields
    obj = {};
    obj.from_digits = from_digits;
    obj.to_digits = to_digits;
    obj.dimensions = dimensions;
    obj.uclasses = uclasses;

    wfmx = wfmx(1:3:size(wfmx, 1), from_digits:to_digits);
    classes = classes(1:3:size(classes, 1));
    
    % Inputs
    inputs  = wfmx';    

    % Create a Self-Organizing Map
    disp('Create SOM object...')
    net = selforgmap(dimensions);
    
    % Train the Network
    disp('Training ...')
    [net, tr] = train(net,inputs);

    % Test the Network
    outputs = net(inputs);
    
    % Calculate ratios
    disp('Calculate ratios...')
    n = dimensions(1)*dimensions(2);
    nums = zeros(n, length(uclasses));
    nums_perc = zeros(n, length(uclasses));
    for i = 1 : n,
        
        ind = find(outputs(i,:)==1);

        class_inside = classes(ind);
        for j = 1 : length(uclasses),
            num_elems = sum(class_inside == uclasses(j));
            nums(i,j) = num_elems;
            nums_perc(i,j) = num_elems/length(class_inside);            
        end;
    end;
    
   
    obj.cmat = nums;
    obj.pcmat = nums_perc;
    obj.net = net;

end