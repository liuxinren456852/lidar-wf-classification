function obj = train_discr(classes, gparams)

    % Linear classifier
    obj.clfier = fitcdiscr(gparams, classes);

    %Quadratic clssifier
    %clfier = fitcdiscr(sum_vals, classes,...
    %    'discrimType','quadratic');

    % Predict
    pred_class = predict(obj.clfier, gparams);

    % Calcualte ratios
    cmat = confusionmat(classes, pred_class);
    dcmat = diag(cmat);
    pcmat = cmat;
    
    for i = 1 : length(dcmat),
        dcmat(i) = dcmat(i) / (sum(cmat(i,:)) + sum(cmat(:,i)) - cmat(i,i) );
        
        pcmat(:,i) = pcmat(:,i) ./ sum(pcmat(:,i));
        %pcmat(i, :) = pcmat(i, :) ./ sum(pcmat(i, :));
        
        if isnan(pcmat(:,i)),
            pcmat(:,i) = 0;
        end;
    end;

    obj.cmat = cmat;
    obj.dcmat = dcmat;
    obj.pcmat = pcmat';

end

