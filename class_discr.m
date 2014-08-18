function res = class_discr(obj,  gparams)

    % Predict
    pred_class = predict(obj.clfier, gparams);
    
    % Results
    res.classes = pred_class;
    res.ratios = obj.pcmat(pred_class, :);

end

